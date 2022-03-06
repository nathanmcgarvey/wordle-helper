# wordle-helper
A small "Wordle" helper script

```
Usage: ./wordle.bash [-d] [-e <excluded characters>] [-i <required characters>] [-l <length of word>] [-p <addtional GREP pattern>]

  -d    Do not score duplicate letters higher.
            E.g. should "eases" or "arose" score higher? "e" and "s" are very frequent letters,
            but it may be disadvantageous to guess duplicate letters.
  -e    Exclude these letters. (The gray tiles in the original Wordle.)
  -i    Include/require these letters. (The yellow/green tiles in the original Wordle.)
  -l    Set a custom World length. (Defaults to five (5) as in the oringinal Wordle.)
  -p    Filter via a custom regex (GREP) pattern. Useful for the green tiles in the original Wordle.
            E.g. ".r[^o].e" would imply r as the second letter and e as the last letter and o as not the third letter.
```

Examples:

```
./wordle.bash -d
Removing '.' from the possible letters
Number of letters tested: 26
Letters tested: z y x w v u t s r q p o n m l k j i h g f e d c b a
Number of words: 5931
...
Character counts:
2733 e
2620 s
2465 a
...
Searching for most-likely to hit word:
fuzzy (fuyz): 2475
puppy (puy): 2683
...
raise (aeirs): 11332
arose (aeors): 11352
```



```
./wordle.bash -i o -p '.r[^o].e'
...
Searching for most-likely to hit word:
orate (orate): 5
```



```
./wordle -d

raise (aeirs): 11332
arose (aeors): 11352
```  

Guessed "arose"... the "o" came back as green, everything else gray.

```
./wordle.bash -d -e aers -p '..o..'
...
block (bcklo): 124
bloch (bchlo): 130
cloth (chlot): 132
```

Guessed "cloth"... correct!
