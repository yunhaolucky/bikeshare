#### Station Clustering with k-means
![](https://googledrive.com/host/0B47woKFE0zXedWZNcHFXU3kyUTA/sum_square_k.png)
I pick k = 6 because it achieves a relatively small sum of squares within groups with a relatively small k.
```
size  max_diss   av_diss  diameter separation
[1,]  120  4.767038 0.6650007  5.015183  0.5737825
[2,]   66  3.247279 1.6179415  4.570141  0.5737825
[3,]   46  6.730754 3.2666578  8.909357  1.1886132
[4,]   34  6.058743 3.0891961  8.594874  1.4416707
[5,]   17 20.501932 6.9504544 22.762304  2.4222733
[6,]   36 17.474640 5.2296720 20.391698  2.2757812
```
Sum of Squares in each cluster
```
640049.5 393156.7 641737.7 453309.1 195013.2 487572.7
```
![](https://googledrive.com/host/0B47woKFE0zXedWZNcHFXU3kyUTA/cluster_center.png)
![](https://googledrive.com/host/0B47woKFE0zXedWZNcHFXU3kyUTA/clusplot.png)

For each cluster, I build a regression model(rides ~ poly(time,3)).
```
cluster 1: rmsle = 2.511275
cluster 2: rmsle = 13.76251
cluster 3: rmsle = 30.42643
cluster 4: rmsle = 47.51951
cluster 5: rmsle = 77.58368
cluster 6: rmsle = 71.70215
```
I also tried poisson regression.
```
cluster 1: rmsle = 0.9664579
cluster 2: rmsle = 1.069417
cluster 3: rmsle = 1.146109
cluster 4: rmsle = 0.9256405
cluster 5: rmsle = 1.159719
cluster 6: rmsle = 1.169191
```
