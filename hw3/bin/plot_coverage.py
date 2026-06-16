#!/usr/bin/env python3
import sys
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import pandas as pd

depth_file = sys.argv[1]
sample = sys.argv[2]
out = sys.argv[3]

df = pd.read_csv(depth_file, sep="\t", header=None, names=["contig", "pos", "depth"])

# берем самый длинный контиг чтобы не рисовать сотни графиков
biggest = df.groupby("contig")["pos"].max().idxmax()
sub = df[df["contig"] == biggest]

plt.figure(figsize=(12, 4))
plt.fill_between(sub["pos"], sub["depth"])
plt.axhline(sub["depth"].mean(), color="red", linestyle="--", label="mean")
plt.title(sample + " coverage (" + biggest + ")")
plt.xlabel("position")
plt.ylabel("depth")
plt.legend()
plt.savefig(out, dpi=150, bbox_inches="tight")
