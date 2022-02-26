/* See LICENSE file for copyright and license details. */
/* Default settings; can be overriden by command line. */

static int instant = 0;
static int topbar = 1;                      /* -b  option; if 0, dmenu appears at bottom     */
/* -fn option overrides fonts[0]; default X11 font or font set */
static const char *fonts[] = {
	"mono:size=11",
    "JoyPixels:pixelsize=11:antialias=true:autohint=true"
};
//static const char nord = "#81cbff";
//static const char gruvbox = "#689d6a";
static const char *prompt      = NULL;      /* -p  option; prompt to the left of input field */
//static const char *colors[SchemeLast][2] = {
//	/*     fg         bg       */
//	[SchemeNorm] = { "#bbbbbb", "#222222" },
//	[SchemeSel] = { "#bbbbbb",  "#005577"},
//	[SchemeOut] = { "#000000", "#00ffff" },
//};
static const char *colors[SchemeLast][2] = {
	/*     fg         bg       */
	[SchemeNorm] = { "#93A1A1", "#201c24" },
	[SchemeSel] = { "#bbbbbb",  "#8265E6"},
	[SchemeOut] = { "#000000", "#00ffff" },
};
/* -l option; if nonzero, dmenu uses vertical list with given number of lines */
static unsigned int lines      = 0;

/*
 * Characters not considered part of a word while deleting words
 * for example: " /?\"&[]"
 */
static const char worddelimiters[] = " ";
