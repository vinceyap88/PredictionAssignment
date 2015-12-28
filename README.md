# Practical Machine Learning Course Project

This project contains one Rmd script([PMLProj01.Rmd](https://github.com/vinceyap88/PredictionAssignment/blob/master/PMLProj01.Rmd)) which will generate the analysis of building the prediction model of the the manner applied in weight lifting exercises(WLE) based on the dataset from [Human Activity Recognition Research ](http://groupware.les.inf.puc-rio.br/har). The input dataset can also be obtained from Coursera:

    a. [Training data](https://d396qusza40orc.cloudfront.net/predmachlearn/pml-training.csv)
    b. [Test data](https://d396qusza40orc.cloudfront.net/predmachlearn/pml-testing.csv)
    
## R Packages Dependency

Additional R package `caret`, `randomForest` are required to install before run the script. 

```{r}
install.package("caret")
install.package("randomForest")
```

## Execution of Rmd Script

After the execution of [PMLProj01.Rmd](https://github.com/vinceyap88/PredictionAssignment/blob/master/PMLProj01.Rmd), the output report will be generated as [PMLProj01.html](https://github.com/vinceyap88/PredictionAssignment/blob/master/PMLProj01.html)

## Viewing Gh-pages
The gh-pages of the generated report can be view at [PredictionAssignment](http://vinceyap88.github.io/PredictionAssignment/)
