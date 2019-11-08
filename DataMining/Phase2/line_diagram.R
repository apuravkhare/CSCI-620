knn=c(0.87,0.65,0.72,0.83,0.90)
DT=c(0.87,0.72,0.74,0.84,0.90)
NB=c(0.84,0.68,0.72,0.84,0.89)

# Give the chart file a name.
png(file = "line_diagram.jpg")

# Plot the bar chart.
plot(knn,type = "o",col = "red",
     main = "3 different algorithms")

lines(DT, type = "o", col = "blue")
lines(NB, type = "o", col = "yellow")
# Save the file.
dev.off()
