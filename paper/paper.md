---
title: 'sdmbench: R package for benchmarking species distribution models'
tags:
  - species distribution modeling
  - ecological niche modeling
  - machine learning
  - benchmarking
authors:
  - name: Boyan Angelov
    orcid: 0000-0001-5068-4234
    affiliation:
affiliations:
 - name:
   index: 1
date: 11 July 2018
bibliography: paper.bib
---

# Summary

Species Distribution Modeling (SDM) is an emerging field in ecology. The effects of anthropogenic climate change, habitat destruction (deforestation, pollution) and poaching are observable in ecosystems around the world [@Elith2009]. SDMs have been used to address those challenges with notable success in estimating the effects of climate change on species distributions [@Austin2011], natural reserve planning [@Guisan2013] and predicting invasive species distributions [@Descombes2016].

Steady improvements in analytical tools (new machine learning algorithms and faster processors in particular) and larger amounts of data gathered recently opened up new possibilities in the field. Although researchers benefit from these new tools, they face challenges in method selection and evaluation. In the case of machine learning algorithms, this issue is particularly relevant. How to decide which algorithm to use, knowing that model performance can vary significantly between datasets? And, how do we compare models in a consistent manner, without introducing additional bias? How can we demonstrate the improvement of a new method over the current state-of-the-art?

`sdmbench` is an R package to benchmark machine learning methods for SDM, helping researchers tackle those questions of selection and evaluation. It is inspired by similar projects in computational chemistry [@Wu2017] and healthcare [@Purushotham2017].

`sdmbench` takes a different approach to benchmarking than previously-published software packages. ENMEval [@Muscarella2014] and SDMSelect [@Rochette2017] have also addressed this challenge, but with a focus on the Maximum Entropy (MaxEnt) model and covariate selection. To summarise, the differentiating features of `sdmbench` are:

* consistent species occurrence data acquisition and preprocessing
* consistent environmental data acquisition (both current data and future projections) and preprocessing, domain-specific cross-validation
* integration of a wide variety of machine learning models and plotting utilities
* a graphical user interface (GUI) for inexperienced users

`sdmbench` obtains species occurrence data and environmental variables from GBIF (https://www.gbif.org/) and Worldclim (http://worldclim.org/), respectively. The user can also specify the type (historical data or IPCC projections) and resolution of the climate data. These popular and stable data repositories ensure high data quality. The data processing pipeline relies on external functions. The scrubr [@scrubr] package is used to clean the occurrence data (i.e. removal of duplicates and unlikely coordinates). ENMEval provides domain-specific cross-validation to mitigate spatial autocorrelation effects that might adversely affect model accuracy. An additional processing option that can be specified is data undersampling. This feature introduces synthetic class imbalance in the data that in turn can test the effectiveness of model training on sparse datasets.

`sdmbench` v0.1.2 supports 10 popular machine learning methods in addition to MaxEnt, including neural networks (Tensorflow via Keras). Methods can be compared quantitatively by computing their Area Under the Curve (AUC, a standard procedure for machine learning classification tasks), and visually by inspecting the resulting species distribution maps. The same workflow can also be accomplished in the GUI, allowing for rapid exploration and prototyping.

`sdmbench` is available from GitHub (https://github.com/boyanangelov/sdmbench), and archived on Zenodo (https://doi.org/10.5281/zenodo.1308199).

# Acknowledgements

The author would like to thank Dr. Brandon Seah and Dr. Rick Scavetta for providing feedback on the manuscript.

# References
