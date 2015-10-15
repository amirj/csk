# Clique-based Semantic kernel

Source code for [*Clique-based Semantic Kernel, NLE journal (2015)*](http://dx.doi.org/10.1017/S135132491500008X)

It is possible to reproduce the experiments of the original paper.

## Dependencies:

This code is written in [R]("https://en.wikipedia.org/wiki/R_(programming_language)"). To use it, you will need:

* [R version 3.2.2](http://r-project.org/) or higher
* [RStudio IDE](http://rstudio.com/)

## Project Structure:

The original paper contains two types of experiments which are described in sections 4 and 5 respectively. For convenient use of this package, we built a seperate folder for each experiment:

* `TextSemanticRelatedness`:
    - `doc_concept.csv`: a collection of 50 text documents from (Lee, Pincombe and Welsh 2005). Wikipedia's entites for each document have been recognized by Wikifier (Milne and Witten 2013).
    - `sim.tbl`: the above documents are paired in all possible ways and evaluate using the average human judgments.
    - `G.net`: feature similarity graph contains 2,671 edges between 496 unique concepts.
    - `utils.R`: a set of utilities to calculate correlations and reproduce scatterplots of the original paper.
    - `semanticrelatedness.R`: source code of the text semantic relatedness experiments (section 4).
    - `Text Semantic Relatedness.Rproj`: a project solution in Rstudio which contains a copy of objects.
* `ConceptSimilarity`:
    - `conceptsim.csv`: a collection of 97 *WordNet* concept pairs which is a benchmark data set in the task of concept similarity (Schwartz and Gomez 2011).
    - `G.net`: a subgraph of *WordNet* which contains 2,796 vertices and 3,087 edges by starting from 152 unique concepts (`conceptsim.csv`) and add all neighbors which are reached by all types of semantic relations. This *feature similarity graph* contains 2,812 maximal cliques.
    - `utils.R`: a set of utilities to calculate correlations and reproduce scatterplots of the original paper.
    - `conceptsimilarity.R`: source code of the concept similarity experiments (section 5).
    - `ConceptSimilarityExperiments.Rproj`: a project solution in Rstudio which contains a copy of objects.

## Getting Started:

Navigate to the appropriate folder (`TextSemanticRelatedness` or `ConceptSimilarity`) and run `.Rproj` project file. The project will be opened in RStudio. After that, you can run `semanticrelatedness.R` or `conceptsimilarity.R` in order to reproduce experiments in the section 4 and 5 respectively. Feel free to contact me if you need any further queries.

## Reference:

If you found this code useful, please cite the following paper:

Jadidinejad, A. H.; Mahmoudi, F.; Meybodi, M. R. **[Clique-based semantic kernel with application to semantic relatedness](http://dx.doi.org/10.1017/S135132491500008X)**, *Natural Language Engineering*, 21 (5), pp. 725-742, 2015.

    @article{NLE:10000595,
        Author = {JADIDINEJAD,A. H. and MAHMOUDI,F. and MEYBODI,M. R.},
        Doi = {10.1017/S135132491500008X},
        Issn = {1469-8110},
        Issue = {Special Issue 05},
        Journal = {Natural Language Engineering},
        Month = {11},
        Numpages = {18},
        Pages = {725--742},
        Title = {Clique-based semantic kernel with application to semantic relatedness},
        Url = {http://journals.cambridge.org/article_S135132491500008X},
        Volume = {21},
        Year = {2015},
        Bdsk-Url-1 = {http://journals.cambridge.org/article_S135132491500008X},
        Bdsk-Url-2 = {http://dx.doi.org/10.1017/S135132491500008X}
    }


## License

[Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0)
