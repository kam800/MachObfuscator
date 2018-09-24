#!/usr/bin/ruby

txt_lines = IO.readlines("english_top_1000.txt").map { |w| w.strip }
code_lines = txt_lines.map { |w| "        \"#{w}\"," }
swift_lines = ["enum Words {", "    static let englishTop1000 = ["] << code_lines << "    ]" << "}" << ""
swift_text = swift_lines.join("\n")
IO.write("../MachObfuscator/SymbolMangling/RealWordsMangler/Words.swift", swift_text)
