#' @export matchColumnIndex
matchColumnIndex <- function(vector,
                             data.frame, column,
                             multi=FALSE) {
  stopifnot(is.data.frame(data.frame))
  
  isColName <- column %in% colnames(data.frame)
  isColNum <- is.numeric(column)
  isColInd <- isColNum && (as.integer(column) %in% 1:ncol(data.frame))
  isColRow <- isColNum && identical(as.integer(column), 0L)
  stopifnot(isColName || isColInd || isColRow)
  
  if(isColRow) {
    target <- rownames(data.frame)
  } else {
    target <- unlist(data.frame[, column])
  }

  ## From 1.0-16, multiple mapping is not slow since it is accelerated by C.
  if(multi) {
    index <- mmatch(vector, target)
  } else {
    index <- match(vector, target)
  }
  
  return(index)
}

#' Match a column in data.frame to a master vector
#' 
#' Given a vector known as master vcector, a data.frame and one column of the
#' data.frame, the function \code{matchColumnIndex} matches the values in the
#' column to the master vector, and returns the indices of each value in the
#' column with respect to the vector. The function \code{matchColumn} returns
#' whole or subset of the data.frame, with the matching column in the exact
#' order of the vector.
#' 
#' See more details below.
#' 
#' The function is used to address the following question: how can one order a
#' \code{data.frame} by values of one of its columns, the order for which is
#' given in a vector (known as \dQuote{master vector}). \code{matchColumnIndex}
#' and \code{matchColumn} provide thoroughly-tested implementation to address
#' this question.
#' 
#' For \code{one-to-one} cases, where both the column and the vector have no
#' duplicates and can be matched one-to-one, the question is straightforward to
#' solve with the \code{match} function in R. In \code{one-to-many} or
#' \code{many-to-many} matching cases, the parameter \code{multi} determines
#' whether multiple rows matching the same value should be shown. If
#' \code{mutli=FALSE}, then the sorted data.frame that are returned has exactly
#' the same row number as the input vector; otherwise, the returned data.frame
#' has more rows. See the examples below.
#' 
#' In either case, in the returned \code{data.frame} object by
#' \code{matchColumn}, values in the column used for matching are overwritten
#' by the master vector.If \code{multi=TRUE}, the order of values in the column
#' is also obeying the order of the master vector, with exceptions of repeating
#' values casued by mutliple matching.
#' 
#' The \code{column} parameter can be either character string or non-negative
#' integers. In the exceptional case, where \code{column=0L} (\dQuote{L}
#' indicates integer), the row names of the \code{data.frame} is used for
#' matching instead of any of the columns.
#' 
#' Both functions are NA-friendly, since NAs in neither vector nor column
#' should break the code.
#' 
#' @aliases matchColumnIndex matchColumn
#' @param vector A vector, probably of character strings.
#' @param data.frame A \code{data.frame} object
#' @param column The column name (character) or index (integer between 1 and
#' the column number), indicating the column to be matched. Exceptionally
#' \code{0} is as well accepted, which will match the row names of the
#' \code{data.frame} to the given vector.
#' @param multi Logical, deciding what to do if a value in the vector is
#' matched to several values in the data.frame column. If set to \code{TRUE},
#' all rows containing the matched value in the specified column are returned;
#' otherwise, when the value is set to \code{FALSE}, one arbitrary row is
#' returned. See details and examples below.
#' @return For \code{matchColumnIndex}, if \code{multi} is set to \code{FALSE},
#' an integer vector of the same length as the master vector, indicating the
#' order of the \code{data.frame} rows by which the column can be re-organized
#' into the master vector. When \code{multi} is \code{TRUE}, the returning
#' object is a list of the same length as the master vector, each item
#' containing the index (indices) of data.frame rows which match to the master
#' vector.
#' 
#' For \code{matchColumn}, a data.frame is always returned. In case
#' \code{multi=FALSE}, the returning data frame has the same number of rows as
#' the length of the input master vector, and the column which was specified to
#' match contains the master vector in its order. If \code{multi=TRUE},
#' returned data frame can contain equal or more numbers of rows than the
#' master vector, and multiple-matched items are repeated.
#' @author Jitao David Zhang <jitao_david.zhang@@roche.com>
#' @seealso See \code{\link{match}} for basic matching operations.
#' @examples
#' 
#' df <- data.frame(Team=c("HSV", "BVB", "HSC", "FCB", "HSV"),
#'                  Pkt=c(25,23,12,18,21),
#'                  row.names=c("C", "B", "A", "F", "E"))
#' teams <- c("HSV", "BVB", "BRE", NA)
#' ind <- c("C", "A", "G", "F", "C", "B", "B", NA)
#' 
#' matchColumnIndex(teams, df, 1L, multi=FALSE)
#' matchColumnIndex(teams, df, 1L, multi=TRUE)
#' matchColumnIndex(teams, df, "Team", multi=FALSE)
#' matchColumnIndex(teams, df, "Team", multi=TRUE)
#' matchColumnIndex(teams, df, 0, multi=FALSE)
#' matchColumnIndex(ind, df, 0, multi=FALSE)
#' matchColumnIndex(ind, df, 0, multi=TRUE)
#' 
#' matchColumn(teams, df, 1L, multi=FALSE)
#' matchColumn(teams, df, 1L, multi=TRUE)
#' matchColumn(teams, df, "Team", multi=FALSE)
#' matchColumn(teams, df, "Team", multi=TRUE)
#' matchColumn(ind, df, 0, multi=FALSE)
#' matchColumn(ind, df, 0, multi=TRUE)
#' 
#' @export matchColumn
matchColumn <- function(vector,
                        data.frame, column,
                        multi=FALSE) {
  index <- matchColumnIndex(vector, data.frame, column, multi=multi)
  if(multi) {
    vector <- rep(vector,
                  sapply(index,length))
    index <- unlist(index)
  }
  res <- data.frame[index,,drop=FALSE]
  if(!(is.numeric(column) && identical(as.integer(column), 0L))) {
    res[, column] <- vector
  } else {
    vec <- make.unique(as.character(vector))
    if(!any(is.na(vec)))
      rownames(res) <- vec
    else
      rownames(res) <- NULL
  }
  return(res)
}
