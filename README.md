vagrant-tsuru
=============
  This is a tsuru box with golang, tsuru, gandalf git, bzr, mercurial
  provisioned.   

  Now it abyss provisioned.
  If abyss need install more python module by pip, you should edit 
  cookbooks/tsuru/recipes/default.rb and use python_pip to install it.
  Because now do not support requirements.txt file.

Usage
=====
  git submodule init && git submodule update
  
  vagrant up 



