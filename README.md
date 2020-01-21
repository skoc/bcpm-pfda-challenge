# Brain Cancer Predictive Modeling <img src="https://raw.githubusercontent.com/skoc/bcpm-pfda-challenge/master/img/pfda-participant.png" align="right" alt="logo" height="100" width="100" />

<img src="https://raw.githubusercontent.com/skoc/bcpm-pfda-challenge/master/img/challenge-details.png" align="right" alt="summary" height="400" width="500" />

This is my solution for the [precisionFDA Brain Cancer Predictive Modeling and Biomarker Discovery Challenge](https://precision.fda.gov/challenges/8)

Steps that I followed in my solution:

- Feature selection with ([L0Learn] (https://github.com/hazimehh/L0Learn)) Fast Best Subset Selection for both Gene Expression and CNV data
- Then gradient boosting decision tree models are applied as a predictive model for the selected features with l0learn
- Three different boosting models are used: XGBoost ([Chen and Guestrin, 2016](https://doi.org/10.1145/2939672.2939785)), LightBGM ([Ke et al., 2017](https://papers.nips.cc/paper/6907-lightgbm-a-highly-efficient-gradient-boosting-decision)), and CatBoost ([Prokhorenkova et al., 2018](https://papers.nips.cc/paper/7898-catboost-unbiased-boosting-with-categorical-features)).
