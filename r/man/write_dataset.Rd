% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dataset-write.R
\name{write_dataset}
\alias{write_dataset}
\title{Write a dataset}
\usage{
write_dataset(
  dataset,
  path,
  format = c("parquet", "feather", "arrow", "ipc", "csv"),
  partitioning = dplyr::group_vars(dataset),
  basename_template = paste0("part-{i}.", as.character(format)),
  hive_style = TRUE,
  existing_data_behavior = c("overwrite", "error", "delete_matching"),
  max_partitions = 1024L,
  ...
)
}
\arguments{
\item{dataset}{\link{Dataset}, \link{RecordBatch}, \link{Table}, \code{arrow_dplyr_query}, or
\code{data.frame}. If an \code{arrow_dplyr_query}, the query will be evaluated and
the result will be written. This means that you can \code{select()}, \code{filter()}, \code{mutate()},
etc. to transform the data before it is written if you need to.}

\item{path}{string path, URI, or \code{SubTreeFileSystem} referencing a directory
to write to (directory will be created if it does not exist)}

\item{format}{a string identifier of the file format. Default is to use
"parquet" (see \link{FileFormat})}

\item{partitioning}{\code{Partitioning} or a character vector of columns to
use as partition keys (to be written as path segments). Default is to
use the current \code{group_by()} columns.}

\item{basename_template}{string template for the names of files to be written.
Must contain \code{"{i}"}, which will be replaced with an autoincremented
integer to generate basenames of datafiles. For example, \code{"part-{i}.feather"}
will yield \verb{"part-0.feather", ...}.}

\item{hive_style}{logical: write partition segments as Hive-style
(\code{key1=value1/key2=value2/file.ext}) or as just bare values. Default is \code{TRUE}.}

\item{existing_data_behavior}{The behavior to use when there is already data
in the destination directory.  Must be one of "overwrite", "error", or
"delete_matching".
\itemize{
\item "overwrite" (the default) then any new files created will overwrite
existing files
\item "error" then the operation will fail if the destination directory is not
empty
\item "delete_matching" then the writer will delete any existing partitions
if data is going to be written to those partitions and will leave alone
partitions which data is not written to.
}}

\item{max_partitions}{maximum number of partitions any batch may be
written into. Default is 1024L.}

\item{...}{additional format-specific arguments. For available Parquet
options, see \code{\link[=write_parquet]{write_parquet()}}. The available Feather options are
\itemize{
\item \code{use_legacy_format} logical: write data formatted so that Arrow libraries
versions 0.14 and lower can read it. Default is \code{FALSE}. You can also
enable this by setting the environment variable \code{ARROW_PRE_0_15_IPC_FORMAT=1}.
\item \code{metadata_version}: A string like "V5" or the equivalent integer indicating
the Arrow IPC MetadataVersion. Default (NULL) will use the latest version,
unless the environment variable \code{ARROW_PRE_1_0_METADATA_VERSION=1}, in
which case it will be V4.
\item \code{codec}: A \link{Codec} which will be used to compress body buffers of written
files. Default (NULL) will not compress body buffers.
\item \code{null_fallback}: character to be used in place of missing values (\code{NA} or
\code{NULL}) when using Hive-style partitioning. See \code{\link[=hive_partition]{hive_partition()}}.
}}
}
\value{
The input \code{dataset}, invisibly
}
\description{
This function allows you to write a dataset. By writing to more efficient
binary storage formats, and by specifying relevant partitioning, you can
make it much faster to read and query.
}
\examples{
\dontshow{if (arrow_with_dataset() & arrow_with_parquet() & requireNamespace("dplyr", quietly = TRUE)) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}
# You can write datasets partitioned by the values in a column (here: "cyl").
# This creates a structure of the form cyl=X/part-Z.parquet.
one_level_tree <- tempfile()
write_dataset(mtcars, one_level_tree, partitioning = "cyl")
list.files(one_level_tree, recursive = TRUE)

# You can also partition by the values in multiple columns
# (here: "cyl" and "gear").
# This creates a structure of the form cyl=X/gear=Y/part-Z.parquet.
two_levels_tree <- tempfile()
write_dataset(mtcars, two_levels_tree, partitioning = c("cyl", "gear"))
list.files(two_levels_tree, recursive = TRUE)

# In the two previous examples we would have:
# X = {4,6,8}, the number of cylinders.
# Y = {3,4,5}, the number of forward gears.
# Z = {0,1,2}, the number of saved parts, starting from 0.

# You can obtain the same result as as the previous examples using arrow with
# a dplyr pipeline. This will be the same as two_levels_tree above, but the
# output directory will be different.
library(dplyr)
two_levels_tree_2 <- tempfile()
mtcars \%>\%
  group_by(cyl, gear) \%>\%
  write_dataset(two_levels_tree_2)
list.files(two_levels_tree_2, recursive = TRUE)

# And you can also turn off the Hive-style directory naming where the column
# name is included with the values by using `hive_style = FALSE`.

# Write a structure X/Y/part-Z.parquet.
two_levels_tree_no_hive <- tempfile()
mtcars \%>\%
  group_by(cyl, gear) \%>\%
  write_dataset(two_levels_tree_no_hive, hive_style = FALSE)
list.files(two_levels_tree_no_hive, recursive = TRUE)
\dontshow{\}) # examplesIf}
}
