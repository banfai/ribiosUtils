% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/keepMaxStatRow.R
\name{keepMaxStatRow}
\alias{keepMaxStatRow}
\alias{isMaxStatRow}
\alias{keepMaxStatRowInd}
\title{KEEP ROWS WITH THE MAXIMUM STATISTIC}
\usage{
keepMaxStatRow(
  matrix,
  keys,
  keepNArows = TRUE,
  stat = function(x) mean(x, na.rm = TRUE),
  levels = c("rownames", "attribute", "discard"),
  ...
)
}
\arguments{
\item{matrix}{A numeric matrix}

\item{keys}{A vector of character giving the keys the rows are mapped to. A
common scenario is that each row represents one probeset, while the vector
keys give the genes that the probesets are mapped to. Thus keys can be
redundant, namely multiple probesets can map to the same gene.}

\item{keepNArows}{Logical, whether rows with \code{NA} as their keys should
be kept (\code{TRUE}) or should be discarded (\code{FALSE})}

\item{stat}{The function to calculate the univariate statistic. By default
the \code{NA}-robust mean is used.}

\item{levels}{How should the information of the levels of keys, e.g. unique
keys, be kept. \code{dicard} will discard this information, \code{rownames}
will make the unique keys (potentially with \code{NA}s) as row names of the
output matrix, and \code{attribute} will append an attribute named
\code{levels} to the output matrix.}

\item{\dots}{Other parameters passed to the \code{stat} function}
}
\value{
A numeric matrix with rows mapped to unique keys, selected by the
maximum statistics. See examples below
}
\description{
A common task in expression analysis is to collapse multiple features that
are mapped to the same gene by some statistic. This function does this job
by keeping the matrix row (normally features) with the higheest statistic
specified by the user.
}
\details{
\code{isMaxStatRow} returns a logical vector, with rows with maximal
statistics each key as \code{TRUE} and otherwise as \code{FALSE}.
\code{keepMaxStatRowInd} returns the integer indices of such rows. Finally
\code{keepMaxStatRow} returns the resulting matrices.

For use see examples
}
\examples{

myFun1 <- function(x) mean(x, na.rm=TRUE)
myFun2 <- function(x) sd(x, na.rm=TRUE)
mat1 <- matrix(c(1,3,4,-5,
                 0,1,2,3,
                 7,9,5,3,
                 0,1,4,3), ncol=4, byrow=TRUE)
keys1 <- c("A", "B", "A", "B")

isMaxStatRow(mat1, keys1, stat=myFun1)
isMaxStatRow(mat1, keys1, stat=myFun2)

keepMaxStatRowInd(mat1, keys1, stat=myFun1)
keepMaxStatRowInd(mat1, keys1, stat=myFun2)

keepMaxStatRow(mat1, keys1, stat=myFun1)
keepMaxStatRow(mat1, keys1, stat="myFun2")
keepMaxStatRow(mat1, keys1, stat="myFun2", levels="discard")
keepMaxStatRow(mat1, keys1, stat="myFun2", levels="attribute")

mat2 <- matrix(c(1,3,4,5,
                 0,1,2,3,
                 7,9,5,3,
                 0,1,4,3,
                 4,0,-1,3.1,
                 9,4,-3,2,
                 8,9,1,2,
                 0.1,0.2,0.5,NA,
                 NA, 4, 3,NA), ncol=4, byrow=TRUE,
               dimnames=list(LETTERS[1:9], NULL))
keys2 <- c("A", "B", "A", "B", NA, NA, "C", "A", "D")

isMaxStatRow(mat2, keys2, keepNArows=FALSE, stat=myFun1)
keepMaxStatRowInd(mat2, keys2, keepNArows=FALSE, stat=myFun1)

keepMaxStatRow(mat2, keys2, keepNArows=FALSE, stat=myFun1)
keepMaxStatRow(mat2, keys2, keepNArows=TRUE, stat=myFun1)
keepMaxStatRow(mat2, keys2, keepNArows=TRUE, stat=myFun1, levels="discard")
keepMaxStatRow(mat2, keys2, keepNArows=TRUE, stat=myFun1, levels="attribute")

}
\author{
Jitao David Zhang <jitao_david.zhang@roche.com>
}
