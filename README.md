# seaStarProcessingSegmentation

## Main codes

codes inside: 
seaStarProcessingSegmentation/

### mainFeaturesExtraction

Main code for extracting sea star cellular features
from segmentations. Segmentations should be
in .tif or .tiff format.
Some paths must be changed by user --> inPath
Both raw images and segmented images should be
inside inPath directory. 2 Folders are needed.

#### DATA STRUCTURE

fullPathTo\SeaStarSegmentations <br />
├── segmentedImages                 # Folder with segmented images <br />
│   ├── SegmentedImg1.tif           # Segmented image 1 <br />
│   ├── SegmentedImg2.tif           # Segmented image 2 <br />
│   └── ...                         # etc. <br />
├── originalImages                  # Folder with raw images <br />
│   ├── OriginalImg1.tif            # Raw image 1 <br />
│   ├── OriginalImg2.tif            # Raw image 2 <br />
│   └── ...                         # etc <br />
└── <br />


### mainFeaturesExtractionBulk

Same as mainSegmentation but for processing
several folders.
Main code for extracting sea star cellular features
from segmentations. Segmentations should be
in .tif or .tiff format.
Some paths must be changed by user --> inPath
Both raw images and segmented images should be
inside each one of the inPath folders

#### DATA STRUCTURE

fullPathTo\SeaStarSegmentations <br />
├── segmentedImages                 # Folder with segmented images <br />
│   ├── SegmentedImg1.tif           # Segmented image 1 <br />
│   ├── SegmentedImg2.tif           # Segmented image 2 <br />
│   └── ...                         # etc. <br />
├── originalImages                  # Folder with raw images <br />
│   ├── OriginalImg1.tif            # Raw image 1 <br />
│   ├── OriginalImg2.tif            # Raw image 2 <br />
│   └── ...                         # etc <br />
└── <br />


### mainVoronoiPacking

Main code for whole voronoi packing processing for comparing voronoi models against
real data.
Uses makeVoronoiPacking function

User must change some paths.

#### DATA STRUCTURE

fullPathTo\SeaStarSegmentations <br />
├── segmentedImages                 # Folder with segmented images <br />
│   ├── SegmentedImg1.tif           # Segmented image 1 <br />
│   ├── SegmentedImg2.tif           # Segmented image 2 <br />
│   └── ...                         # etc. <br />
├── originalImages                  # Folder with raw images <br />
│   ├── OriginalImg1.tif            # Raw image 1 <br />
│   ├── OriginalImg2.tif            # Raw image 2 <br />
│   └── ...                         # etc <br />
└── <br />

### mainCurvatureEmbryoSurface

Main code for curvature analysis of the SeaStar embryo.
Coordinates of outter layer cell centroids and inner layer
cell centroids are needed.
Inner layer and outer layer can be
extracted using getInnerOuterLateralFromEmbryos
An excell file with estimated info of all 3 principal axes of the embryo
are needed as well as estimated mean cell height. This was done
manually using FIJI.

inPath directory should have a folder for each movie. Inside those
folders, a folder for each one of the 3 stages.
Then, inside those folders, all timepoints (.tif) and a .mat file with
relevant information of the original images. This can be extracted using
mainSegmentation.m

#### DATA STRUCTURE


D:\Path\to\curvatureAnalysis\data   <br />
├── excellFile.xls <br />
├── movie1                           # Folder with movie 1 data <br />
│   ├── originalImageName.mat        # Relevant data of raw images (obtained using FIJI)    <br />  
│   │   ├─stage128 <br />
│   │   │   ├── timepoint1.tif       # Segmented image stage 128 timepoint 1 <br />
│   │   │   ├── timepoint2.tif       # Segmented image stage 128 timepoint 2 <br />
│   │   │   └── ...                  # etc. <br />
│   │   ├─stage256 <br />
│   │   │   ├── timepoint1.tif       # Segmented image stage 256 timepoint 1 <br />
│   │   │   ├── timepoint2.tif       # Segmented image stage 256 timepoint 2 <br />
│   │   │   └── ...                  # etc. <br />
│   │   ├─stage512 <br />
│   │   │   ├── timepoint1.tif       # Segmented image stage 512 timepoint 1 <br />
│   │   │   ├── timepoint2.tif       # Segmented image stage 512 timepoint 2 <br />
│   │   │   └── ...                  # etc. <br />
├── movie2                           # Folder with movie 2 data <br />
│   └── ...                          # etc. <br />
└── ... <br />


#### .mat table structure

| ID_Tissue | Major_Axis | Major_Axis | Minor_Axis | Avg_CellHeight |
|-----------|------------|------------|------------|----------------|
| tissue_1  | 123.45     | 123.45     | 123.45     | 123.45         |
| ...       | ...        | ...        | ...        | ...            |
|           |            |            |            |                |


## Voronoi
codes inside: 
seaStarProcessingSegmentation/Voronoi/

### MakeVoronoiModels

Function to make voronoi tesselations from centroids of image
segmentations. It is used to compare voronoi models with real data.
This function is called from seaStarProcessingSegmentation/mainVoronoiPacking <br />
#### INPUTS: <br />
originalImage: raw image <br />
labelledImage: segmented image <br />
#### OUTPUTS: <br />
voronoiSeaStar: voronoi tesselation <br />

## featuresExtraction

codes inside: 
seaStarProcessingSegmentation/featuresExtraction

Codes for feature extraction called by the main codes: tissue and cell morphological features, scutoids data, and code for aggregate the data into a table.

Documentation can be found inside the .m files.

## preprocessing

codes inside: 
seaStarProcessingSegmentation/preprocessing

Codes for sea star embryos preprocessing. Needed for a correct cell segmentation.

Documentation can be found inside the .m files.

## utils

codes inside: 
seaStarProcessingSegmentation/utils

General useful codes.

Documentation can be found inside the .m files.

