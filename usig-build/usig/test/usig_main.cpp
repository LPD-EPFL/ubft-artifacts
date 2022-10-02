// Copyright (c) 2018 NEC Laboratories Europe GmbH.
//
// Authors: Sergey Fedorov <sergey.fedorov@neclab.eu>
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#undef NDEBUG // make sure `assert()` is not an empty macro
#include <cassert>
#include <cstdlib>
#include <cstdbool>
#include <cstring>
#include <cstdio>

#include <iostream>
#include <vector>
#include <string>
#include <random>

#include "usig.h"
#include "latency.hpp"

const char *enclave_file;

// NOTE: We only do *limited* testing here. For instance, we don't
// check correctness of the signature (certificate) produced by the
// enclave because it's cumbersome to do so in C. That's easier to
// test in Golang, together with the certificate verification
// implementation.

static void test_init_destroy()
{
        sgx_enclave_id_t eid;

        assert(usig_init(enclave_file, &eid, NULL, 0) == SGX_SUCCESS);
        assert(usig_destroy(eid) == SGX_SUCCESS);
}

static inline bool signature_is_equal(sgx_ec256_signature_t *s1,
                                      sgx_ec256_signature_t *s2)
{
        return memcmp(s1, s2, sizeof(sgx_ec256_signature_t)) == 0;
}

static void test_seal_key()
{
        sgx_enclave_id_t usig;
        void *sealed_data;
        size_t sealed_data_size;

        assert(usig_init(enclave_file, &usig, NULL, 0) == SGX_SUCCESS);
        assert(usig_seal_key(usig, &sealed_data,
                             &sealed_data_size) == SGX_SUCCESS);
        assert(usig_destroy(usig) == SGX_SUCCESS);
        assert(usig_init(enclave_file, &usig, sealed_data,
                         sealed_data_size) == SGX_SUCCESS);
        free(sealed_data);
        assert(usig_destroy(usig) == SGX_SUCCESS);
}

static void test_create_ui()
{
        sgx_enclave_id_t usig;
        uint64_t e1, e2;
        void *sealed_data;
        size_t sealed_data_size;
        sgx_ec256_signature_t s1, s2, s3;
        uint64_t c1, c2, c3;
        sgx_sha256_hash_t digest = "TEST DIGEST";

        assert(usig_init(enclave_file, &usig, NULL, 0) == SGX_SUCCESS);
        assert(usig_seal_key(usig, &sealed_data,
                             &sealed_data_size) == SGX_SUCCESS);
        assert(usig_get_epoch(usig, &e1) == SGX_SUCCESS);

        assert(usig_create_ui(usig, digest, &c1, &s1) == SGX_SUCCESS);
        // The first counter value must be one
        assert(c1 == 1);

        assert(usig_create_ui(usig, digest, &c2, &s2) == SGX_SUCCESS);
        // The counter must be monotonic and sequential
        assert(c2 == c1 + 1);
        // Certificate must be unique for each counter value
        assert(!signature_is_equal(&s1, &s2));

        // Destroy USIG instance
        assert(usig_destroy(usig) == SGX_SUCCESS);

        // Recreate USIG using the sealed secret from the first instance
        assert(usig_init(enclave_file, &usig, sealed_data,
                         sealed_data_size) == SGX_SUCCESS);
        assert(usig_get_epoch(usig, &e2) == SGX_SUCCESS);

        assert(usig_create_ui(usig, digest, &c3, &s3) == SGX_SUCCESS);
        // Must fetch a fresh counter value
        assert(c3 == 1);

        // Check for uniqueness of the epoch and certificate produced
        // by the new instance of the enclave
        assert(e1 != e2);
        assert(!signature_is_equal(&s1, &s3));

        assert(usig_destroy(usig) == SGX_SUCCESS);
        free(sealed_data);
}

static std::string random_string(std::size_t length) {
        const std::string CHARACTERS = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";

        std::random_device random_device;
        std::mt19937 generator(random_device());
        std::uniform_int_distribution<> distribution(0, CHARACTERS.size() - 1);

        std::string random_string;

        for (std::size_t i = 0; i < length; ++i)
        {
                random_string += CHARACTERS[distribution(generator)];
        }

        return random_string;
}

int main(int argc, const char **argv)
{
        assert(argc >= 3);
        enclave_file = argv[1];
        auto message_size = std::stoll(argv[2]);
        auto iter_cnt = argc == 4 ? std::stoll(argv[3]) : 1000000;

        sgx_enclave_id_t usig;
        uint64_t e1;
        void *sealed_data;
        size_t sealed_data_size;
        sgx_ec256_signature_t s1;
        uint64_t c1;
        sgx_sha256_hash_t digest = "TEST DIGEST";

        // Initialization and some simple checks before starting the test
        assert(usig_init(enclave_file, &usig, NULL, 0) == SGX_SUCCESS);
        assert(usig_seal_key(usig, &sealed_data,
                             &sealed_data_size) == SGX_SUCCESS);
        assert(usig_get_epoch(usig, &e1) == SGX_SUCCESS);
        assert(usig_create_ui(usig, digest, &c1, &s1) == SGX_SUCCESS);
        assert(c1 == 1);
        

        std::string input_str = random_string(message_size);
        std::vector<uint8_t> input_digest(input_str.size());
        memcpy(input_digest.data(), input_str.c_str(), input_str.size());
        hmac_t hmac;
        uint64_t c2 = 0;

        dory::LatencyProfiler profiler_create(iter_cnt > 20000 ? 10000 : 0);
        dory::LatencyProfiler profiler_verify(iter_cnt > 20000 ? 10000 : 0);

	for (int i = 1; i <= iter_cnt; i++) {
                bool valid = false;

                auto start_create_ts = std::chrono::steady_clock::now();	        
                assert(usig_create_ui_shared_key(usig, input_digest.data(), input_digest.size(), &c2, hmac) == SGX_SUCCESS);

                auto end_create_ts = std::chrono::steady_clock::now();

                assert(usig_verify_ui_shared_key(usig, &c2, hmac, input_digest.data(), input_digest.size(), &valid) == SGX_SUCCESS);
                auto end_verify_ts = std::chrono::steady_clock::now();

                assert(c2 == i);
                assert(valid == true);

                profiler_create.addMeasurement(end_create_ts - start_create_ts);
                profiler_verify.addMeasurement(end_verify_ts - end_create_ts);
	}

        std::cout << std::endl;
        std::cout << "Using the USIG to create a UI for a message of " <<  message_size << " bytes" << std::endl;
        profiler_create.report();

        std::cout << "Using the USIG to verify a UI for a message of " <<  message_size << " bytes" << std::endl;
        profiler_verify.report();
}
