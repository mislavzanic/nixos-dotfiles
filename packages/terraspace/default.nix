with import <nixpkgs> {};
bundlerApp {
  pname = "terraspace";
  exes = ["terraspace"];
  gemdir = ./.;
}
