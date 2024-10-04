------------------
Hypothesis testing
------------------


Def
--------------

Objctv: determine if a claim about a population is likely to be true or not

Two Hypothesis:
- Null Hypothesis (H0) = State there is NO difference OR NO relationship between 2 vars
- Alternative Hypothesis (H1) = States that there is a difference or relationship between 2 vars

EX.:
u_i = Apple mean weight by producer i
H0: u_1 = u_2
H1: u_1 != u_2

c_ab = Correlation between a and b
H0: c_ab = 0
H1: c_ab != 0

P-value: probability of observing the sample if H0 is true

Significance level (alpha): threshold for rejecting the H0
!!!!!!!!!!!!!!!
* if p-value < alpha => reject H0
    * if p-value is unavailable the use critical value
        > it happens with non-std distributed
        > small sample sizes
        > complex models
!!!!!!!!!!!!!!!

* usually 0.05 or 0.01

Errors:
- Type I = H0 reject but it is true
- Type II = H0 accepted but it is false


Types
--------------

1. T-test: compare means of two groups
    * assumens data are normally distributed
    * sample of 30+

- 1 sample
    > t = (X - u_0) / (s / n),
            X = mean of the sample
            u_0 = null hypothesis mean
            s = std dev of the sample
            n = sample size

- independent (2 samples) (for independent groups)
    => We need t-statistic (t), degrees of freedom (df) and alpha
    > t = (X_1 - X_2) / sqrt[(s1^2/n1) + (s2^2/n2)],
            X_i = sample i mean 
            si = std dev of group i
            ni = sample size of group i
            sqrt[(s1^2/n1) + (s2^2/n2)] = SE
    > df = (n1 + n2) - 2
    => Then we use df and alpha in a t-distribution table to get the critical value (u_0) for our distribution
    => if t < u_0 => reject H0

* The Higher the SE the less precise is the diff between means

- paired (2 samples) (for paired groups) (ex.: a same group of students take 2 tests after receiving 2 different teaching methods)
    > t = (X_d - u_d) / (sd / n),
            X_d = X_1 - X_2
            u_d = u_1 - u_2 (H0 -> 0)
            sd = std dev of the paired diff (ex.: student 1 score on test 1 - test 2 is a paired diff)
            n = number of pairs
    > df = n - 1
* if testing against a constant value, use paired, but t calculation uses the samples and not the difference
* if t < 0 we can assume the average is lower than the estimated


2. ANOVA (Analysis of Variance): compare means 2+ groups
    * assumes normality
    * compares variance between groups and within groups
    * if between > within then means are not close else means are close
    * assumes F distribution
    * sample of 20+

- one-way
    * assumes homogeneity (same variance for all pops the samples come from)
    * assumes indepent groups
    => variation between (VB), variation within (VW), F-statistic (F)
    > VB = Σ (n_i * (X_i - X)^2), * regression sum of squares
        n_i = samples of i
        X_i = mean of i
        X = overall mean
    > VW = Σ ( Σ ( (X_ij - X_i)^2 ) ), * error sum of squares
        X_ij = value j of group i
        X_i = mean of i
    > dfb = (nb - 1), 
        nb = num of groups
    > dfw = (n - nb),
        n = total sample size
    > F = (VB / dfb) / (VW / dfw)
* if F > f_0 (critical value != p-value) then reject H0
* possible post ANOVA tests to determine which groups are different: Tukey's HSD (Honestly Significant Difference), Bonferroni correction, and Dunnett's test

* ANOVA can be one-way, two-way, or multi-way depending on the number of factors being analyzed
    > e.g: two-way => do one-way for each factor separately and their interaction

3. Chi-square tests: Used to test the independence or association between two categorical variables.

- goodness of fit: whether a sample of categorical data fits a specific distribution
> χ^2 = Σ (O_i - E_i)^2 / E_i

where:
χ^2 = the chi-square test statistic
O_i = the observed frequency in category i
E_i = the expected frequency in category i under the null hypothesis (specific distrib)


- independence: relationship between two categorical variables
> χ^2 = Σ [(O_ij - E_ij)^2 / E_ij]

where:
χ^2 = the chi-square test statistic
O_ij = the observed frequency in cell (i,j)
E_ij = the expected frequency in cell (i,j) under the null hypothesis (they are independent)

> E_ij = (R_i * C_j) / n, 
    R_i = marginal frequency of row i => sum of the values in row i
    C_j = marginal frequency of column j => sum of the values in col j
    n = sample size

df =  (nrows - 1)(ncols - 1)

4. Regression analysis: Used to determine the relationship between a dependent variable and one or more independent variables.

Others: 
- in case data is not normally distributed
- less powerful and may require larger datasets

5. Mann-Whitney U test: non-parametric to compare the medians of 2 independent groups
6. Wilcoxon signed-rank test: non-parametric to compare the medians of 2 related groups.
7. Kruskal-Wallis test: non-parametric to compare the medians of 3+ independent groups.
8. Friedman test: non-parametric to compare the medians 3+ related groups.
