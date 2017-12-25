# Inquirly Development Workflow

## Feature Branches during like Small feature/CR release

During a Small feature/CR, all development should be done off of the `inquirly_live_uat` branch.

For larger features that require either more than 1 commit or more than 1 workday, developers should create a feature branch off of the `inquirly_live_uat`. For example to work on a "csv_upload_refactor" feature, run the following:

    $ git checkout inquirly_live_uat
    $ git pull origin inquirly_live_uat
    $ git checkout -b csv_upload_refactor

Commits should be made on that branch and should be made early and often.

    ... Edited Code ...
    $ git add .
    $ git commit -m "csv_upload_refactor: customer info model validation changes"
    ... Edited Code ...
    $ git add .
    $ git commit -m "csv_upload_refactor: organization,batch fields added in csv file"

Feature branches should be commited and pushed nightly to Github, even if the code is in a non-working state. Feature branches are private and multiple developers should generally not be working on the same feature branch.

    # At End of Day
    $ git add .
    $ git commit -m "csv_upload_refactor: dowload csv view file added"
    $ git push origin csv_upload_refactor

### Preparing for a merge and merging

Once the feature has been tested locally and is in working shape it should be ready to merge. Before merge developer should do the following:

1. Commit any uncommited code
2. Fetch the latest `inquirly_live_uat` branch and rebase against `inquirly_live_uat` (this will effectively do a reverse merge, and bring your branch up to date with the latest commits in inquirly_live_uat)
      
        $ git checkout inquirly_live_uat
        $ git pull origin inquirly_live_uat
        $ git checkout csv_upload_refactor
        $ git rebase inquirly_live_uat csv_upload_refactor

3. Ensure you have properly tested the changed code and have added "failure" specs that handle failures.
4. Run a full test suite and ensure all tests are passing
5. Do a squash commit with the details of the branch:

        $ git checkout inquirly_live_uat
        $ git pull origin inquirly_live_uat
        # If anything new comes in here, repeat step 2 above (i.e. do another rebase)
        $ git merge --squash csv_upload_refactor
        $ git commit -m "CSV Upload Refactor Feature See: https://github.com/railsfactory/inquirly..."
        $ git push origin inquirly_live_uat
  
        # Finally (optionally) delete the branch locally 
        $ git branch -D csv_upload_refactor
  
        # Delete the branch remotely
        $ git push origin :csv_upload_refactor

### Why this workflow for features?

1. Allow single features to packed together in a single commit, which makes it easier to track where changes have come from.
2. GitHub makes it easy to view differences between branches (e.g. https://github.com/railsfactory/inquirly/compare/inquirly_live_uat...csv_upload_refactor ) so viewing the progress of features and doing code reviews on WIP code is a lot easier.
3. The Git log stays clean and doesn't end up with thousands of merge commits.

## Bug Fixes during a Small feature/CR release

1. If there are small bug fixes that can easily be solved in a single commit, features branches are not necessary, however it's important to:

   1. Limit the fix to a single commit and a single bug and include a reference to the bug in the commit message
   2. Do a rebase before pushing to prevent merge commit
   3. Run the test suite before committing 

This looks like:

	$ git checkout inquirly_live_uat
	$ git pull origin inquirly_live_uat
	    ... Make Commits to fix small bug ...
	$ git add . 
	$ git commit -m "Fix to small typo  https://github.com/railsfactory/inquirly... "
	    # Do a rebase pull to make sure you are up to date
	$ git pull --rebase origin inquirly_live_uat
	    .. Fix any merge issue, if any...
	$ git push origin inquirly_live_uat


2. For larger fixes, either more than 2 commit or more than 1 workday, create a feature branch off of inquirly_live_uat:


         $ git checkout inquirly_live_uat
         $ git pull origin inquirly_live_uat
         $ git checkout -b csv_upload_qa_fixes
   
         # .. Commit any changes, test locally and run tests ...
   
         $ git checkout inquirly_live_uat
         $ git pull origin inquirly_live_uat
         $ git checkout csv_upload_qa_fixes
         $ git rebase inquirly_live_uat csv_upload_qa_fixes
         $ git checkout inquirly_live_uat
         $ git merge --squash csv_upload_qa_fixes
         $ git commit -m "Fixed CSV upload bug fixes See: https://github.com/railsfactory/inquirly..."
         $ git push origin inquirly_live_uat
   
         # delete the branch locally
         $ git branch -D csv_upload_qa_fixes
   
         # delete the branch remotely (if necessary)
         $ git push origin :csv_upload_qa_fixes