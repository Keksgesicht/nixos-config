lib:
rec {
  fs = lib.filesystem;
  forEach = lib.lists.forEach;
  flatList = lib.lists.flatten;
  listFilesRec = fs.listFilesRecursive;
}
