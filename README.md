# Brain Cancer Predictive Modeling and Biomarker Discovery Challenge<img src="https://raw.githubusercontent.com/skoc/bcpm-pfda-challenge/master/img/pfda-participant.png" align="right" alt="logo" height="100" width="100" />

![License: MIT](https://img.shields.io/github/license/skoc/bcpm-pfda-challenge.svg)

<br>
<img src="https://raw.githubusercontent.com/skoc/bcpm-pfda-challenge/master/img/challenge-details.png" align="right" alt="summary" height="320" width="410" />

This is my solution for the [precisionFDA Brain Cancer Predictive Modeling and Biomarker Discovery Challenge](https://precision.fda.gov/challenges/8)

Steps that I followed in my solution:

- Feature selection with L0Learn 'Fast Best Subset Selection' ([Hazimeh et al., 2018](https://github.com/hazimehh/L0Learn)) for both Gene Expression and CNV data
- Then gradient boosting decision tree models are applied as a predictive model to the selected features with l0learn
- Three different boosting models are used: XGBoost ([Chen and Guestrin, 2016](https://doi.org/10.1145/2939672.2939785)), LightGBM ([Ke et al., 2017](https://papers.nips.cc/paper/6907-lightgbm-a-highly-efficient-gradient-boosting-decision)), and CatBoost ([Prokhorenkova et al., 2018](https://papers.nips.cc/paper/7898-catboost-unbiased-boosting-with-categorical-features)).
