library(data.table)
library(reshape2)
# data.csv is already cleaned using vi / excel
# to remove the total rows, commas, pound signs
# un-merge the merged cells and duplicate the labels
data <- fread('data.csv', stringsAsFactors = F, header=F, sep="\t")
pubs <- as.character(data[1])[2:ncol(data)]
year <- as.character(data[2])[2:ncol(data)]
uni <- data[3:nrow(data),as.character(V1)]
m <- as.matrix(data[3:nrow(data), -1, with=F])
x <- data.table(t(m), year=year, publisher=pubs)
setnames(x, colnames(x)[1:153], uni)
y <- melt.data.table(x, id.vars = c("year", "publisher"), variable.name = "institute", value.name = "cost")
write.table(y, "journal_costs_melted.tab", col.names=T, row.names=F, quote=F, sep="\t")

data <- fread('journal_costs_melted.tab', header = T)
data[,.(total=sum(cost, na.rm = T)),by=institute][total>0][order(-total)][1:20]
data[,.(total=sum(cost, na.rm=T)), by=publisher][order(-total)]
