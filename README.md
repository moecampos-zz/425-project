# 425-project
Shiver me timbers

## Project Structure
1. All data files (raw or processed) are located in the top-level `data` directory.
2. Scripts for analysis are included in the top-level `R` directory. The text analysis code is contained in a rmarkdown file at markdown/ReviewAnalysis.Rmd.
* The script `R/cleaning.R` includes the code for loading the data used for visualization in the shiny application. It is sourced in local environment of `server.R`, so you should avoid putting long running code in this file. It should just load the data from disk and do various data munging operations. The result is a data.frame `listings` with the data for visualization and modeling.
3. The rest of the project is structured like a normal Shiny application. `server.R` contains the backend code. By backend I mean code that generates data used by the U/I, i.e. it runs the R scripts. `ui.R` contains the front-end code. This is code that changes the web-app for the user, i.e the html and css seen by the user.
4. `www` contains anything else needed for the webapp. Most importantly `styles.css` which contains any css for the web-page.

## Running the Code
1. Without pulling the code from github:

The site is located [here](https://joshloyal.shinyapps.io/425-project/).

If you want to run the laster master app without cloneing the repository:
```R
library(shiny)

shiny::runGitHub("425-project", "moecampos")
```

2. To edit the code:
First clone the repository

```bash
git clone git@github.com:moecampos/425-project.git
```

Then before editing the code remember to pull the latest changes. To do this run the following in the top level directory:

```bash
git pull --rebase --prune
```

Run the above command EVERY TIME you sit down to edit the code.

Once you are satisfied with the changes you have made you need to commit your code. To do this
run the following command

```bash
git commit -am 'my awesome changes'
```

Where should replace 'my awesome changes' with a description of what you did.

This commit only exists locally though. To add your changes to the repository run

```bash
git push origin master
```
