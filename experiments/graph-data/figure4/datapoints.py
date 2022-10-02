#!/usr/bin/env python3

import os
from prelude import plt, color, marker
from prelude import compute_bar_pos, annotate_data_labels
from matplotlib.ticker import AutoMinorLocator
from matplotlib.patches import Patch

def latency(smr, app, params, percentile):
    replicated = 'un' if smr == 'unreplicated' else ''
    machine = 2 if smr == 'unreplicated' else 4
    client = 'mu' if smr == 'unreplicated' else smr
    path = 'fastpath-' if smr == 'ubft' else ''
    with open(f'../apps/{smr}/logs/e2e-latency-{path}{app}-{replicated}replicated-{params}/m{machine}/logs/{client}-client.txt') as f:
        return next(int(l.split(' ')[-1]) for l in f if f'{percentile}th-percentile (ns):' in l) / 1000.

def main():
    apps = {
        'flip': {
            'params': 's32',
        },
        'memc': {
            'params': 'k16-v32-g30-s80',
        },
        'liquibook': {
            'params': 'b50',
        },
        'redis': {
            'params': 'k16-v32-g30-s80'
        }
    }

    smrs = {
        'unreplicated': {
            'display': 'Unreplicated',
        },
        'mu': {
            'display': 'Mu',
        },
        'ubft': {
            'display': 'uBFT fast path',
        },
    }

    legends = [
        Patch(facecolor=color.next(), hatch=hatch, label=smr['display'], linestyle='None', edgecolor='white')
        for (smr, hatch)
        in zip(smrs.values(), ('----', '....', 'xxxx'))
    ]

    fig, subplots = plt.subplots(1, len(apps), figsize=(3.35, 1.4), tight_layout=True)

    for plot in subplots:
        plot.tick_params(axis='both', which='major', pad=0.5)
        plot.tick_params(axis='both', which='minor', pad=0.5)

    print(os.path.splitext(os.path.basename(__file__))[0])

    line_style = dict(
        edgecolor='white',
        linewidth='0'
    )

    errobar_style = dict(
        # elinewidth=0.5,     # width of error bar line
        ecolor='black',   # color of error bar
        capsize=2.0,        # cap length for error bar
        # capthick=0.5        # cap thickness for error bar
    )

    bar_width = 0.20

    for subplot, (app_name, app) in zip(subplots, apps.items()):
        for smr_i, smr in enumerate(smrs):
            ps = [latency(smr, app_name, app['params'], p) for p in (50, 90, 95)]
            true_x = [compute_bar_pos(1, bar_width, len(smrs), smr_i)]
            bar = subplot.bar(true_x, ps[1], 0.8*bar_width, yerr=[[ps[1] - ps[0]], [ps[2] - ps[1]]], color=legends[smr_i].get_facecolor(), **errobar_style, **line_style, hatch=legends[smr_i].get_hatch())
            annotate_data_labels(true_x, [ps[2]], [ps[1]], subplot)
            
            for cap in bar.errorbar.lines[1]:
                cap.set_marker("_")
                cap.set_markeredgewidth(0.25)
                cap.set_linewidth(1)

        subplot.set_xticks([])
        subplot.set_xlim(0.5, 1.5)
        subplot.yaxis.set_minor_locator(AutoMinorLocator())
        _, automax = subplot.get_ylim()
        subplot.set_ylim(0, automax * 1.3)
        subplot.grid(axis='y', which='major', linestyle='--', linewidth='0.5')
        subplot.grid(axis='y', which='minor', linestyle=':', linewidth='0.25')
        subplot.set_title(app_name.capitalize(), pad=0)
        subplot.set_axisbelow(True)
    
    subplots[0].set_ylabel('Latency (µs)', labelpad=1)

    fig.legend(handles=legends, bbox_to_anchor=(0,1.001,1,0.015),
        loc="center", edgecolor='black', borderaxespad=0, ncol=3)

    plt.savefig(os.path.splitext(os.path.basename(__file__))[0] + '.pdf', format='pdf', bbox_inches = 'tight', pad_inches=0.01)

if __name__ == "__main__":
    main()
