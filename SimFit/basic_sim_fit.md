Simulate, Fit, GLMs...
================
Josh Nowak

-   [Overview](#overview)
-   [Simulation](#simulation)
    -   [Linear Predictor (Simulation)](#linear-predictor-simulation)
    -   [Link Function (Simulation)](#link-function-simulation)
    -   [Probability Distribution (Simulation)](#probability-distribution-simulation)
-   [Fitting a Model](#fitting-a-model)
    -   [Linear Predictor (Fit)](#linear-predictor-fit)
    -   [Link Function (Fit)](#link-function-fit)
    -   [Probability Distribution (Fit)](#probability-distribution-fit)
-   [Conclusion](#conclusion)
-   [Other thoughts](#other-thoughts)
    -   [Effects Parameterization](#effects-parameterization)
    -   [Means Parameterization](#means-parameterization)

------------------------------------------------------------------------

Overview
--------

Simulation is an effective way to learn about data, models and how the two interact.

**Do you want to tell the model what the effect of *rain* is or do you want to ask what the effect is?**

If you are asking what the effect of *x* is then you are fitting a model, but if you are telling the model what the effect is you are simulating.

Consider this document a coarse introduction to GLMs, simulating and fitting data. For further plain language description and details try one of the following:

-   [Ecological Models and Data in R by Ben M. Bolker](https://www.amazon.com/Ecological-Models-Data-Benjamin-Bolker/dp/0691125228/ref=pd_lpo_sbs_14_t_2?_encoding=UTF8&psc=1&refRID=BV91P16AZ7K9WHP7E36M)
-   [Introduction to WinBUGS for Ecologists by Marc Kery](https://www.amazon.com/Introduction-WinBUGS-Ecologists-Bayesian-regression/dp/0123786053)

I typically suggest that students read the first 4 chapters of the Bolker book and then proceed to work through the entire Kery book. The order may not matter, but Bolker's text will be slightly more formal and precise whereas Kery will use plain language that is very accessible. Once you have a thorough understanding of GLMs then I would work through the following text:

-   [Data Analysis Using Regression and Multilevel/Hierarchical Models by Andrew Gelman and Jennifer Hill](https://www.amazon.com/Analysis-Regression-Multilevel-Hierarchical-Models/dp/052168689X/ref=sr_1_1?s=books&ie=UTF8&qid=1519154665&sr=1-1&keywords=gelman+and+hill)

For examples of applications in ecology try:

-   [Hierarchical Modeling and Inference in Ecology by J. Andrew Royle and Robert M. Dorazio](https://www.amazon.com/Hierarchical-Modeling-Inference-Ecology-Metapopulations/dp/0123740975/ref=sr_1_1?s=books&ie=UTF8&qid=1519154295&sr=1-1&keywords=royle+dorazio+ecology)

-   [Bayesian Population Analysis using WinBUGS: A Hierarchical Perspective](https://www.amazon.com/Bayesian-Population-Analysis-using-WinBUGS/dp/0123870208/ref=sr_1_1?s=books&ie=UTF8&qid=1519154495&sr=1-1&keywords=winbugs+population+ecology)
-   In addition to these texts I have found the writings of Ruth King and Olivier Gimenez particularly useful. The books, book chapters and papers written by these authors are accessible and typically come with code.

That said, my interests lie in the estimation of demographic parameters and describing how populations change through time. If your interests focus on other areas of ecology you might find more relevant examples for applications in ecology.

------------------------------------------------------------------------

Simulation
----------

Recall the three parts of a GLM:

1.  linear predictor (deterministic)
2.  link (maps linear predictor to distribution)
3.  distribution (stochastic)

### Linear Predictor (Simulation)

To simulate data we will begin by creating a linear predictor where rainfall has some effect on growth. This is our description of the biological system.

The basic form of our model is `y <- b0 + b1 * rain`.

Create some covariate (e.g. rain) data

``` r
rain <- rnorm(10, 0, 1)
rain
```

    ##  [1] -1.7395898  1.1794794 -0.3246989  1.7145374  0.6378590  0.9381521
    ##  [7]  2.2917779 -0.8734899 -0.5373132 -1.3475449

We choose to draw our rain data from a distribution with a mean of 0 and a standard deviation of 1. Why? It is common, in some circles, to center and scale covariate data by subtracting the mean and dividing by the standard deviation.

`(x - mean(x))/sd(x)` or simply `scale(x, center = T)`

When we apply this technique the covariate data will end up with a mean of about 0 and standard deviation close to 1, so I chose to skip all that and just draw from a normal with mean = 0 and sd = 1 (the default values of rnorm).

We now need to define the values of b0 and b1, so...

``` r
b0 <- 1
b1 <- 0.8
```

Quick question, are we asking what the effect of rain is or telling the model? Notice that we are not defining the response (i.e. `y`) and it is the response which we would observe in the field, right?

Build the full linear predictor

``` r
y <- b0 + b1 * rain
y
```

    ##  [1] -0.39167184  1.94358354  0.74024086  2.37162992  1.51028717
    ##  [6]  1.75052171  2.83342235  0.30120805  0.57014946 -0.07803588

### Link Function (Simulation)

In this case we will choose the normal distribution and the associated link function for the normal is the identity link (i.e. don't do anything). Why? What is the range of the normal? If the link function is the identity then we have nothing to do.

### Probability Distribution (Simulation)

Apply the outcome of the linear predictor to chosen probability distribution

``` r
obs <- rnorm(y, y, sd = 1)
obs
```

    ##  [1] -0.63685517  1.44988079  0.02349985  3.08867006  2.00975315
    ##  [6] -0.27030262  4.40907668 -1.17783941  1.29516191 -1.09918076

*What role did the outcome of the linear predictor (i.e. y) play?* *Are large positive values of rain associated with large growth? Why?*

We have simulated our first data set, whoot! Wait, so what? Well, one reason to do this is to help define hypotheses. We have explicitly stated a hypothesis here in terms of things we can actually measure in the field and the direction and magnitude of the effect of rain on growth. We have also unknowingly(?) completed half of a power analysis. If the effect of rain is `0.8` and we collect `10` samples can we detect that effect? Well, to know the answer we have to fit a model, opposite of simulation, sort of. Using our quote from above, we have told the model what the effect of rain is and now we want to ask what the values is to complete the circle, like algebra, you liked algebra, right?

------------------------------------------------------------------------

Fitting a Model
---------------

Recall the three parts of a GLM:

1.  linear predictor (deterministic)
2.  link (maps linear predictor to distribution)
3.  distribution (stochastic)

### Linear Predictor (Fit)

In R we define the linear predictor using a *formula*. Recall we defined our simulation using:

`y <- b0 + b1 * rain`.

Now to translate that into a formula we would write

`y ~ rain` or `y ~ 1 + rain`

So, basically we just substituded `<-` for `~` and dropped `b0` and `b1`. Formulas can get weird and someday you will need to read the help page or find some great blog post, but for the moment...

### Link Function (Fit)

When simulating we didn't apply a link function and the same holds for fitting.

### Probability Distribution (Fit)

We chose to apply a Normal distribution to our growth problem. We will use the same distribution when fitting a model. In R we can call this model with `lm`, think linear model.

Before we fit our model let's combine our covariate data (i.e. rain) and response. These are also called x and y or dependent and independent variables.

``` r
fit_inpt <- tibble::tibble(rain = rain, obs = obs)
fit_inpt
```

    ## # A tibble: 10 x 2
    ##          rain         obs
    ##         <dbl>       <dbl>
    ##  1 -1.7395898 -0.63685517
    ##  2  1.1794794  1.44988079
    ##  3 -0.3246989  0.02349985
    ##  4  1.7145374  3.08867006
    ##  5  0.6378590  2.00975315
    ##  6  0.9381521 -0.27030262
    ##  7  2.2917779  4.40907668
    ##  8 -0.8734899 -1.17783941
    ##  9 -0.5373132  1.29516191
    ## 10 -1.3475449 -1.09918076

Nice, so we have a two column tibble containing our independent variable (i.e. covariate or x) and the field observations (i.e. dependent variable or y) associated with the measured values of x.

``` r
fit <- lm(obs ~ rain, data = fit_inpt)
summary(fit)
```

    ## 
    ## Call:
    ## lm(formula = obs ~ rain, data = fit_inpt)
    ## 
    ## Residuals:
    ##      Min       1Q   Median       3Q      Max 
    ## -2.04993 -0.52878  0.09775  0.68184  1.24120 
    ## 
    ## Coefficients:
    ##             Estimate Std. Error t value Pr(>|t|)   
    ## (Intercept)   0.6824     0.3401   2.007  0.07970 . 
    ## rain          1.1696     0.2618   4.467  0.00209 **
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## Residual standard error: 1.063 on 8 degrees of freedom
    ## Multiple R-squared:  0.7138, Adjusted R-squared:  0.678 
    ## F-statistic: 19.95 on 1 and 8 DF,  p-value: 0.002092

We fit a model. Notice that the summary of the model shows us estimated values of rain and the intercept. Do these values look similar to `b0` and `b1`? They should, but they may not because we only have 10 observations. Hopefully you can see that in this case we asked what the effect of rain is on growth. I like to think of fitting and simulation as opposites. For example, if I simulate data then in order to fit a model I simply have to *flip the problem over*. In the simulation example we defined `rain`, `b0` and `b1` to create `obs`, we then flipped the problem over to fit the model and defined `rain` and `obs` to get estimates of `b0` and `b1`.

If we wanted to use this example as a power analysis then we would simply repeat this process 10,000 times and then summarize the outcome. That is a topic for another day, but just know that this is the foundation.

------------------------------------------------------------------------

Conclusion
----------

Simulating and fitting data are powerful techniques that help us define hypotheses, explore biology and design studies. The basic techniques described here can be extrapolated to complex models and sampling schemes. I encourage you to develop simulations for your own system and questions. I think you will find the insights invaluable when designing your study.

------------------------------------------------------------------------

Other thoughts
--------------

Matrix multiplication is often used to simplify or describe the linear predictor. This idea becomes clear if we build the model matrix. Consider the model matrix from above:

``` r
mm <- model.matrix(~ rain)
mm
```

    ##    (Intercept)       rain
    ## 1            1 -1.7395898
    ## 2            1  1.1794794
    ## 3            1 -0.3246989
    ## 4            1  1.7145374
    ## 5            1  0.6378590
    ## 6            1  0.9381521
    ## 7            1  2.2917779
    ## 8            1 -0.8734899
    ## 9            1 -0.5373132
    ## 10           1 -1.3475449
    ## attr(,"assign")
    ## [1] 0 1

We now have a model matrix that provides an alternative description of our model. Applying matrix multiplication we get the same answer as y above:

``` r
mat_mult <- mm %*% c(b0, b1)

all(y == mat_mult)
```

    ## [1] TRUE

``` r
cbind(mat_mult, y)
```

    ##                          y
    ## 1  -0.39167184 -0.39167184
    ## 2   1.94358354  1.94358354
    ## 3   0.74024086  0.74024086
    ## 4   2.37162992  2.37162992
    ## 5   1.51028717  1.51028717
    ## 6   1.75052171  1.75052171
    ## 7   2.83342235  2.83342235
    ## 8   0.30120805  0.30120805
    ## 9   0.57014946  0.57014946
    ## 10 -0.07803588 -0.07803588

The model matrix becomes more useful and obvious when we consider a categorical covariate. Let's suppose that growth now depends on rain and sex. We can create a factor describing whether each individual is male or female using the following

``` r
fit_inpt$sex <- as.factor(sample(c("M", "F"), nrow(fit_inpt), replace = T))
fit_inpt
```

    ## # A tibble: 10 x 3
    ##          rain         obs    sex
    ##         <dbl>       <dbl> <fctr>
    ##  1 -1.7395898 -0.63685517      F
    ##  2  1.1794794  1.44988079      M
    ##  3 -0.3246989  0.02349985      F
    ##  4  1.7145374  3.08867006      F
    ##  5  0.6378590  2.00975315      M
    ##  6  0.9381521 -0.27030262      M
    ##  7  2.2917779  4.40907668      F
    ##  8 -0.8734899 -1.17783941      F
    ##  9 -0.5373132  1.29516191      M
    ## 10 -1.3475449 -1.09918076      M

Now using the magical properties of factors

``` r
model.matrix(~ rain + sex, data = fit_inpt)
```

    ##    (Intercept)       rain sexM
    ## 1            1 -1.7395898    0
    ## 2            1  1.1794794    1
    ## 3            1 -0.3246989    0
    ## 4            1  1.7145374    0
    ## 5            1  0.6378590    1
    ## 6            1  0.9381521    1
    ## 7            1  2.2917779    0
    ## 8            1 -0.8734899    0
    ## 9            1 -0.5373132    1
    ## 10           1 -1.3475449    1
    ## attr(,"assign")
    ## [1] 0 1 2
    ## attr(,"contrasts")
    ## attr(,"contrasts")$sex
    ## [1] "contr.treatment"

What happened? We now have a reference category for females that is part of the intercept and a new column for Male. This is called an effects parameterization. The intercept is the value of growth when sex is female and the value of rain is 0. Remember when we centered and scaled the covariate and in the back of your mind you thought it was a dumb idea because it is easier to talk about the effect of n cm (or gasp, inches) of rain? Well, because we centered and scaled the intercept is now the value of growth at the mean of rain for a female, which seems more useful than when rain doesn't exist. How do we get the value of male then?

Well, we would take the intercept and add the coefficient for males (call it b2). In this way we see that the coefficient is an adjustment that walks the value of growth from females to males. We could also write a means parameterization. In the case of the means parameterization we would estimate a unique *intercept* for each level of sex or more simply one for males and one for females.

``` r
model.matrix(~ -1 + rain + sex, data = fit_inpt)
```

    ##          rain sexF sexM
    ## 1  -1.7395898    1    0
    ## 2   1.1794794    0    1
    ## 3  -0.3246989    1    0
    ## 4   1.7145374    1    0
    ## 5   0.6378590    0    1
    ## 6   0.9381521    0    1
    ## 7   2.2917779    1    0
    ## 8  -0.8734899    1    0
    ## 9  -0.5373132    0    1
    ## 10 -1.3475449    0    1
    ## attr(,"assign")
    ## [1] 1 2 2
    ## attr(,"contrasts")
    ## attr(,"contrasts")$sex
    ## [1] "contr.treatment"

What just happened? All along the formula has assumed that the intercept is present in the model. The intercept is denoted by the number 1 and if we want to drop the intercept, say to fit a means parameterization of a model, we can use -1 to *drop* the intercept. Let's play with the examples and fit the models to see if we can see the pattern. Above we created data fit\_inpt that includes a column for sex. Using our knowledge of effects and means parameterizations we can write the formulas and fit our models.

#### Effects Parameterization

``` r
summary(lm(obs ~ 1 + rain + sex, data = fit_inpt))
```

    ## 
    ## Call:
    ## lm(formula = obs ~ 1 + rain + sex, data = fit_inpt)
    ## 
    ## Residuals:
    ##      Min       1Q   Median       3Q      Max 
    ## -1.83903 -0.46721  0.09772  0.71898  1.44840 
    ## 
    ## Coefficients:
    ##             Estimate Std. Error t value Pr(>|t|)   
    ## (Intercept)   0.8919     0.4994   1.786  0.11726   
    ## rain          1.1671     0.2731   4.273  0.00369 **
    ## sexM         -0.4181     0.7015  -0.596  0.56996   
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## Residual standard error: 1.109 on 7 degrees of freedom
    ## Multiple R-squared:  0.7276, Adjusted R-squared:  0.6498 
    ## F-statistic:  9.35 on 2 and 7 DF,  p-value: 0.01055

#### Means Parameterization

``` r
summary(lm(obs ~ -1 + rain + sex, data = fit_inpt))
```

    ## 
    ## Call:
    ## lm(formula = obs ~ -1 + rain + sex, data = fit_inpt)
    ## 
    ## Residuals:
    ##      Min       1Q   Median       3Q      Max 
    ## -1.83903 -0.46721  0.09772  0.71898  1.44840 
    ## 
    ## Coefficients:
    ##      Estimate Std. Error t value Pr(>|t|)   
    ## rain   1.1671     0.2731   4.273  0.00369 **
    ## sexF   0.8919     0.4994   1.786  0.11726   
    ## sexM   0.4738     0.4982   0.951  0.37325   
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## Residual standard error: 1.109 on 7 degrees of freedom
    ## Multiple R-squared:  0.7841, Adjusted R-squared:  0.6916 
    ## F-statistic: 8.474 on 3 and 7 DF,  p-value: 0.00993

First off, hopefully the estimated of rain is very similar in both cases. Second, notice that the effect of males in the first model is smaller than the number reported in the second case. The first case describes the difference between females and males at the mean value of rain and the second describes the mean of males. In other words, the first model is describing the effect of being male and the second is the mean male...see what I did there, see that?

Why do I care about this? Convenience (largely). If I want to know the mean growth of males and I have fit a model using an effects parameterization then I can just add the intercept to coefficient for males, right? Sure, but what is the variance of that new estimate? Ouch, that is not fun at all. Right, so if we want to know mean growth of males then if the means parameterization and if we want to know the difference between males and females then use the effects parameterization.
