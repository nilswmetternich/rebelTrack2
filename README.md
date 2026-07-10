# rebeltrack

## Getting Started

### Install `rebeltrack`

1. Create a *Personal Access Token* at https://github.com/settings/tokens/new
1. Install the package (replace XXXXXXXX with the *Personal Access Token*)

```
devtools::install_github("nilswmetternich/rebelTrack2", auth_token="XXXXXXXX")
```

### Load `rebeltrack`

```
library(rebeltrack)
```


### Download datasets

Use the `rebeltrack_download()` function to download the necessary datasets locally. The datasets are downloaded to `~/.rebeltrack` folder.

```
rebeltrack_download()
```

### Load datasets

Load the datasets using `rebeltrack_load_dataset()`

```
dataset <- rebeltrack_load_dataset(type = UCDP_STATE_BASED)
```

### Create RebelTrackDataFrame

```
data <- rebeltrack_dataframe(dataset,
                             side = SIDE_B,
                             period = "month",
                             balanced = TRUE)
```
		
