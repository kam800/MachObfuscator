# MachObfuscator 🔏

MachObfuscator is a programming-language-agnostic [Mach-O](https://en.wikipedia.org/wiki/Mach-O) apps obfuscator (for Apple platforms).

## Current status 🏃‍♂️

✅ – means feature is completed, ❌ – means feature is todo/in-progress.

- ✅ Mach-O iOS
- ✅ Mach-O macOS
- ✅ iOS NIBs (including storyboards)
- ⚠️ macOS NIBs (including storyboards) – does not support bindings yet
- ❌ MOMs (CoreData)
- ❌ Mach-O watchOS
- ❌ Mach-O tvOS
- ❌ Bitcode
- ❌ automatic code re-signing (need to re-sign all images manually, see [resign.sh](resign.sh))

## Overview 🌍

MachObfuscator is a binary symbolic obfuscator. What does it mean? There are a few important terms:

- Obfuscator – a tool which makes software hard to be reverse engineered.
- Binary obfuscator – a type of obfuscator that operates on machine code, not on a source code.
- Symbolic obfuscator – a type of obfuscator that obfuscates only symbol names, does not change program control-flow.

MachObfuscator transforms symbols in [Mach-O](https://en.wikipedia.org/wiki/Mach-O) files directly. Mach-O format is used mainly on Apple platforms as a machine code container for executables and libraries. MachObfuscator doesn't need access to the app source code in order to obfuscate it.

## Demo 🚀

Let's see MachObfuscator obfuscating `SampleApp.app` application:

[![readme_resource/machobfuscator_demo.gif](readme_resource/machobfuscator_demo.gif)](https://asciinema.org/a/yYFq0MCwtX9PWh89wgiuM4aXC)

Results can be seen by opening app's main executable in [MachOView](https://sourceforge.net/projects/machoview/). MachOView shows obfuscated ObjC selectors:

![](readme_resource/selectors_before_titled.png)
![](readme_resource/selectors_after_titled.png)

and obfuscated ObjC class names:
![](readme_resource/classes_before_titled.png)
![](readme_resource/classes_after_titled.png)

Only sample changes are shown above. MachObfuscator changes more Mach-O sections.

## Usage details 🎮

```
$ ./MachObfuscator
usage: ./MachObfuscator [-qvdhtD] [-m mangler_key] APP_BUNDLE|FILE

  Obfuscates application bundle in given directory (APP_BUNDLE) or Mach-O file (FILE) in-place.

Options:
  -h, --help              help screen (this screen)
  -q, --quiet             quiet mode, no output to stdout
  -v, --verbose           verbose mode, output verbose info to stdout
  -d, --debug             debug mode, output more verbose info to stdout
  --dry-run               analyze only, do not save obfuscated files

  --erase-methtype        erase methType section (objc/runtime.h methods may work incorrectly)
  -D, --machoview-doom    MachOViewDoom, MachOView crashes after trying to open your binary (doesn't work with caesarMangler)
  --swift-reflection      obfuscate Swift reflection sections (typeref and reflstr). May cause problems for Swift >= 4.2

  --objc-blacklist-class NAME[,NAME...]     do not obfuscate given classes. Option may occur mutliple times.
  --objc-blacklist-class-regex REGEXP       do not obfuscate classes matching given regular expression. Option may occur mutliple times.
  --objc-blacklist-selector NAME[,NAME...]  do not obfuscate given selectors. Option may occur mutliple times.
  --objc-blacklist-selector-regex REGEXP    do not obfuscate selectors matching given regular expression. Option may occur mutliple times.
 
  --preserve-symtab       do not erase SYMTAB strings
  --erase-section SEGMENT,SECTION    erase given section, for example: __TEXT,__swift5_reflstr
  
  --erase-source-file-names PREFIX   erase source file paths from binary. Erases paths starting with given prefix
                                     by replacing them by constant string
  --replace-cstring STRING           replace arbitrary __cstring with given replacement (use with caution). Matches entire string,
  --replace-cstring-with STRING      adds padding 0's if needed. These options must be used as a pair.

  --skip-all-frameworks              do not obfuscate frameworks
  --skip-framework framework         do not obfuscate given framework
  --obfuscate-framework framework    obfuscate given framework (whitelist for --skip-all-frameworks)

  -m mangler_key,
  --mangler mangler_key   select mangler to generate obfuscated symbols

  --skip-symbols-from-sources PATH
                          Don't obfuscate all the symbols found in PATH (searches for all nested *.[hm] files).
                          This option can be used multiple times to add multiple paths.

  --report-to-console     report obfuscated symbols mapping to console

Development options:
  --xx-no-analyze-dependencies       do not analyze dependencies
  --xx-dump-metadata                 dump ObjC metadata of images being obfuscated
  --xx-find-symbol NAME[,NAME...]    find given ObjC symbol in all analysed images

Available manglers by mangler_key:
  caesar - ROT13 all objc symbols and dyld info
  realWords - replace objc symbols with random words and fill dyld info symbols with numbers
```

## Integration with fastlane 🚀

MachObfuscator can be easily integrated with fastlane builds:

0. Make sure that you have compiled MachObfuscator and [`obfuscate.sh`](obfuscate.sh) script available for fastlane.
1. Build the application IPA as usual. You may sign it, but it can be skipped at this point because after obfuscation the application will have to be resigned.
2. Use `obfuscate.sh` to obfuscate your IPA:
    1. The script requires that path to compiled MachObfuscator is in `MACH_OBFUSCATOR` environment variable.
    2. Pass in absolute path to the IPA you want to obfuscate.
    3. `obfuscate.sh` can also resign the application if you pass certificate name or pass `NO_RESIGN` to resign later using fastlane.
    4. Pass additional MachObfuscator options that you need.
    5. Obfuscated IPA is named like original one with added `_obf.ipa` suffix.   
3. Resign obfuscated IPA from fastlane if you have not used script to do it.
4. You may retain unobfuscated IPA and MachObfuscator logs.

Here is an example fastlane configuration assuming that compiled MachObfuscator and the script are in main project directory, IPA was built to `./exported_ipa/#{TARGET_NAME}.ipa`  and you want final products in `./app` directory:

```ruby
  # Copy unobfusated app 
  rsync(
    destination: "./app/#{IPA_NAME}_unobfuscated.ipa",
    source: "./exported_ipa/#{TARGET_NAME}.ipa"
  )

  # Obfuscate
  # sh runs in fastlane directory not main project directory
  sh("MACH_OBFUSCATOR=../MachObfuscator ../obfuscate.sh ../exported_ipa/#{TARGET_NAME}.ipa NO_RESIGN -v | tee ../app/obfuscation.log")

  # Copy obfuscated app
  rsync(
    destination: "./app/#{IPA_NAME}.ipa",
    source: "./exported_ipa/#{TARGET_NAME}.ipa_obf.ipa"
  )

  # Sign obfuscated app
  resign(
    ipa: "./app/#{IPA_NAME}.ipa",
    signing_identity: "[IDENTITY]",
    provisioning_profile: {
      "#{APP_IDENTIFIER}" => "#{PROVISION_PATH}"
    }
  )
```

## Under the hood 🔧

In a great simplification, MachObfuscator:

1. looks for all executables in the app bundle,
2. searches recursively for all dependent libraries, dependencies of those libraries and so on,
3. searches for all NIB files in the app bundle,
4. discriminates obfuscable files (files in the app bundle) and unobfuscable files (files outside the app bundle),
5. collects Obj-C symbols, export tries and import lists from the whole dependency graph,
6. creates symbols whitelist and symbol blacklist (symbols used in unobfuscable files),
7. mangles whitelist symbols, export tries and import lists using selected mangler,
8. replaces symbols in obfuscable files,
9. clears sections which are optional, 
10. saves all the files at once.

MachObfuscator changes following Mach-O sections:

- `__TEXT, __objc_classname` – mangles symbol names
- `__TEXT, __objc_methname` – mangles symbol names
- `__TEXT, __objc_methtype` –  mangles symbol names or optionally (enabled with `--erase-methtype` parameter) fills whole section with `0`s
- `__TEXT, __swift3_typeref`, `__TEXT, __swift4_typeref`, `__TEXT, __swift5_typeref` – fills whole section with `0`s
- `__TEXT, __swift3_reflstr` , `__TEXT, __swift4_reflstr`,  `__TEXT, __swift5_reflstr` – fills whole section with `0`s
- `LC_DYLD_INFO_ONLY` – mangles export tries and binding lists
- `LC_SYMTAB` – fills whole section with `0`s

`__TEXT, __swift*` are sections used by Swift's reflection mechanism ([`Mirror`](https://developer.apple.com/documentation/swift/mirror)). `Mirror` works even after clearing those sections, just returns less detailed data. `LC_SYMTAB` is used by `lldb`.

MachObfuscator does not affect crash symbolication because [dSYMs](https://docs.fabric.io/apple/crashlytics/missing-dsyms.html) are generated during compilation – that is before obfuscation.

## Contributing 🎁

If you have any idea for improving MachObfuscator, let's chat on Twitter ([@kam800](https://twitter.com/kam800)).

If you want to write some code, but don't feel confortable with Mach-O, I suggest doing some preparations first:

1. Play with [MachOView](https://sourceforge.net/projects/machoview/), open some binaries and try to feel Mach-O layout.
2. Read `/usr/include/mach-o/loader.h` from any macOS.
3. Read `Mach+Loading.swift` from MachObfuscator repo.

## License 👍

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
