## MRes Neuroinformatics Project

#### Graph Theory as an Alzheimer's Disease Diagnostic Instrument in the Context of Functional Brain Connectivity

This repository also includes follow-up work on the MRes project. It was presented at the [BrainModes](http://www.brainmodes.org/) 2014 conference: [poster](./docs/BrainModes2014_poster.pdf) and [link](http://goo.gl/H39ueD) to contribution.

## File structure

- docs - contains thesis, project proposal and posters
- report - contains Latex code for report
- sources - contains source files

## List of programs (*sources* folder)

- mfiles
- misc
    - 4D_header_adapted.mat - used to load data into FieldTrip
- notebooks
    - project_notes.ipynb - contains notes made during the project
    - testing_connectivity.ipynb - some signal processing exploration (Hilbert transforms, filtering)
    - testing_padding.ipynb - explore if MEG data padding is needed
    - plot_full_graph_measures.ipynb - plots graph measures
    - plot_MST_measures.ipynb - plots MST measures
    - statistical_testing.ipynb - code for Functional Data Analysis
    - classification.ipynb - trains classifiers on graph measures

## Required Software

To run the M-files, you would need MATLAB with [FieldTrip](http://www.fieldtriptoolbox.org/) and [Brain Connectivity Toolbox](https://sites.google.com/site/bctnet/). For the Jupyter notebooks, you would need [scikit-learn](http://scikit-learn.org/), [NumPy](http://www.numpy.org/), [SciPy](https://www.scipy.org/) and [matplotlib](http://matplotlib.org/).
