let
  key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCpyqlmmIPUeFZj6Gp57BMctMYKNJ2B/LTc+eagC1tg5SRmuvQvEKK9Sr9/QBAuW5pnZpNucmoT0Al+iJLhpZ87ElwNbqfnUpGfLUeKk3ZKV2Kc4LM2L3gkX5oNi5oS+LUcxhwAvMM2EDsEERR7KlmsvrCWdpO9SWRSxmgU+xNv/JKTD92LwNW0dqASLp3DsVJBKlZVAEPXcUwMGhIhF8faICAZCCb7Y+kyoy2pD17duhgz7lod05A23eYjBQt/JvTJw/BdP86pMoVzD0+nLp9Hi1dvqHZEEbSENqZpFzj67/itVOWcWLGbc0Fx1L9cI+pz9LALCMCUPiFGE7X2lF02qzAz/XRTHY5Cahxzbvhle9THcRC0+3IolvvYNKShq8vTT2cOnF2QbOYtMWAaCGd4oSC08COpGwmisPtyOqSQ3tjfgT24B24cp81AvVsQ+sO9tp19qDpPuEcDRU2ycWbgGRFmkK5Rwuh8DXTEmtu63bEyNrXRZU8dO4mQseKoQbs= mzanic@mzanic-Swift-SF314-54";
in {
  "pm_mail.age".publicKeys = [ key ];
  "gh.age".publicKeys = [ key ];
  "cf.age".publicKeys = [ key ];
}
