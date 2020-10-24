# How to work with `GitHub` submodule

The following steps needs to be done:

## Creating the `Parent repo`

1. Create a private git repo
2. Clone it

## Creating the `Submodule repo`

1. `cd` into newly cloned `parent repo`
2. Open `terminal`
3. Clone submodule repo using `git submodule add <REPOSITORY_URL>`

### Push submodule to parent

1. Type `git add .` and hit ENTER
2. Type `git commit -m "<YOUR_MESSAGE_GOES_HERE>"` and hit ENTER
3. Type `git push origin master` and hit ENTER

### After changes made in the `Submodule repo`

1. Push submodule to it's master branch using the commands stated earlier
2. No further things for now in the submodule.

### Update changes from the `Submodule repo`

1. `cd` into newly cloned `parent repo`
2. Open `terminal`
3. Type `git submodule update --remote test-submodule` and hit ENTER
4. Push all changes to the master branch of the `Parent repo` using the commands stated earlier
5. Ma Sha ALLAH! You are ready to go now.
