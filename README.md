# BTree
BTree implementation imported from SqueakSource
The current repository is waiting for getting cleaned and prepared for inclusion in containers. 

### Load it from a workspace
Open a workspace and evaluate:

    Metacello new
      repository: 'github://pharo-containers/BTree';
      baseline: 'BTree';
      load.

### Load it from `BaselineOfYourProject`
I suggest you use your `baseline: spec` method and inside your version block code, call `self btree: spec` method consisting of:

    btree: spec
      spec
      baseline: 'BTree'
      with: [ spec repository: 'github://pharo-containers/BTree/src' ]
### Source and credits
- Imported it from [SqueakSource](http://www.squeaksource.com/BTree/).
- [Avi Bryant](https://twitter.com/avibryant)
- [Adrian Lienhard](https://twitter.com/adrianlienhard)
- [Ramon Leon](https://twitter.com/ramon_leon)
- [Lukas Renggli](https://twitter.com/renggli)

