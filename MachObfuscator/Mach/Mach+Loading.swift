import Foundation
import MachO

enum MachLoadingError: Error {
    case unsupportedBinary(url: URL, magic: UInt32?)
}

extension Image {
    static func load(url: URL) throws -> Image {
        return try Image(data: Data(contentsOf: url),
                         url: url)
    }

    init(data: Data, url: URL) throws {
        self.url = url
        let magic = data.magic
        switch magic {
        case FAT_CIGAM:
            contents = .fat(Fat(data: data, url: url))
        case MH_MAGIC, MH_MAGIC_64:
            contents = .mach(Mach(data: data, url: url))
        default:
            throw MachLoadingError.unsupportedBinary(url: url, magic: magic)
        }
    }
}

private extension Fat {
    init(data: Data, url: URL) {
        self.data = data
        switch data.magic {
        case FAT_CIGAM:
            let header: fat_header = data.getStruct(atOffset: 0)
            let archs: [fat_arch] = data.getStructs(atOffset: MemoryLayout<fat_header>.size, count: Int(header.nfat_arch.byteSwapped))
            architectures = archs.map { arch in
                Fat.Architecture(data: data, arch: arch, url: url)
            }
        default:
            fatalError("Unsupported fat binary magic \(String(data.magic ?? 0, radix: 0x10, uppercase: true))")
        }
    }
}

private extension Fat.Architecture {
    init(data: Data, arch: fat_arch, url: URL) {
        let range = (Int(arch.offset.byteSwapped) ..< Int(arch.offset.byteSwapped + arch.size.byteSwapped))
        let subdata = data.subdata(in: range)
        offset = UInt64(arch.offset.byteSwapped)
        mach = Mach(data: subdata, url: url)
    }
}

private extension Mach {
    init(data: Data, url: URL) {
        switch data.magic {
        case MH_MAGIC_64:
            self.init(data64: data, url: url)
        case MH_MAGIC:
            self.init(data32: data, url: url)
        default:
            fatalError("Unsupported mach binary magic \(String(data.magic ?? 0, radix: 0x10, uppercase: true))")
        }
    }

    private init(data32: Data, url: URL) {
        let header: mach_header = data32.getStruct(atOffset: 0)

        data = data32
        type = header.filetype == MH_EXECUTE ? .executable : .other
        cpu = Mach.Cpu(type: header.cputype, subtype: header.cpusubtype)
        var platform: Platform?
        rpaths = []
        dylibs = []
        segments = []
        symtab = nil
        dyldInfo = nil

        var cmdsLeft = header.ncmds
        var cursor = MemoryLayout<mach_header>.size
        while cmdsLeft > 0 {
            let command: load_command = data.getStruct(atOffset: cursor)

            switch command.cmd {
            case UInt32(LC_SEGMENT):
                let rawSegment: segment_command = data.getStruct(atOffset: cursor)
                let sections: [section] = data.getStructs(atOffset: cursor + MemoryLayout<segment_command>.size,
                                                          count: Int(rawSegment.nsects))
                segments.append(Segment(segment: rawSegment, sections: sections))
            case UInt32(LC_SYMTAB):
                let symtab_command: symtab_command = data.getStruct(atOffset: cursor)
                symtab = Symtab(symtab_command)
            case LC_DYLD_INFO_ONLY:
                let dyld_info_command: dyld_info_command = data.getStruct(atOffset: cursor)
                dyldInfo = DyldInfo(dyld_info_command)
            case LC_RPATH:
                let rpath_command: rpath_command = data.getStruct(atOffset: cursor)
                let rpath = data.getCString(atOffset: cursor + Int(rpath_command.path.offset))
                rpaths.append(rpath)
            // TODO: handle weaks
            case UInt32(LC_LOAD_DYLIB), UInt32(LC_LOAD_WEAK_DYLIB), UInt32(LC_REEXPORT_DYLIB):
                let dylibCommand: dylib_command = data.getStruct(atOffset: cursor)
                let dylibPath = data.getCString(atOffset: cursor + Int(dylibCommand.dylib.name.offset))
                dylibs.append(dylibPath)
            case UInt32(LC_VERSION_MIN_IPHONEOS), UInt32(LC_VERSION_MIN_MACOSX):
                let version_min_command: version_min_command = data.getStruct(atOffset: cursor)
                platform = Platform(version_min_command)
            case UInt32(LC_BUILD_VERSION):
                let build_version_command: build_version_command = data.getStruct(atOffset: cursor)
                platform = Platform(buildVersion: build_version_command)
            default:
                break
            }
            cursor += Int(command.cmdsize)
            cmdsLeft -= 1
        }
        self.platform = (platform ?? url.platform)!
    }

    private init(data64: Data, url: URL) {
        let header: mach_header_64 = data64.getStruct(atOffset: 0)

        data = data64
        type = header.filetype == MH_EXECUTE ? .executable : .other
        cpu = Mach.Cpu(type: header.cputype, subtype: header.cpusubtype)
        var platform: Platform?
        rpaths = []
        dylibs = []
        segments = []
        symtab = nil
        dyldInfo = nil

        var cmdsLeft = header.ncmds
        var cursor = MemoryLayout<mach_header_64>.size
        while cmdsLeft > 0 {
            let command: load_command = data.getStruct(atOffset: cursor)

            switch command.cmd {
            case UInt32(LC_SEGMENT_64):
                let rawSegment: segment_command_64 = data.getStruct(atOffset: cursor)
                let sections: [section_64] = data.getStructs(atOffset: cursor + MemoryLayout<segment_command_64>.size,
                                                             count: Int(rawSegment.nsects))
                segments.append(Segment(segment: rawSegment, sections: sections))
            case UInt32(LC_SYMTAB):
                let symtab_command: symtab_command = data.getStruct(atOffset: cursor)
                symtab = Symtab(symtab_command)
            case LC_DYLD_INFO_ONLY:
                let dyld_info_command: dyld_info_command = data.getStruct(atOffset: cursor)
                dyldInfo = DyldInfo(dyld_info_command)
            case LC_RPATH:
                let rpath_command: rpath_command = data.getStruct(atOffset: cursor)
                let rpath = data.getCString(atOffset: cursor + Int(rpath_command.path.offset))
                rpaths.append(rpath)
            // TODO: handle weaks
            case UInt32(LC_LOAD_DYLIB), UInt32(LC_LOAD_WEAK_DYLIB), UInt32(LC_REEXPORT_DYLIB):
                let dylibCommand: dylib_command = data.getStruct(atOffset: cursor)
                let dylibPath = data.getCString(atOffset: cursor + Int(dylibCommand.dylib.name.offset))
                dylibs.append(dylibPath)
            case UInt32(LC_VERSION_MIN_IPHONEOS), UInt32(LC_VERSION_MIN_MACOSX):
                let version_min_command: version_min_command = data.getStruct(atOffset: cursor)
                platform = Platform(version_min_command)
            case UInt32(LC_BUILD_VERSION):
                let build_version_command: build_version_command = data.getStruct(atOffset: cursor)
                platform = Platform(buildVersion: build_version_command)
            default:
                break
            }
            cursor += Int(command.cmdsize)
            cmdsLeft -= 1
        }
        self.platform = (platform ?? url.platform)!
    }
}

private extension Mach.Platform {
    init(_ versionMin: version_min_command) {
        switch versionMin.cmd {
        case UInt32(LC_VERSION_MIN_MACOSX):
            self = .macos
        case UInt32(LC_VERSION_MIN_IPHONEOS):
            self = .ios
        default:
            fatalError("unsupported version_min_command.cmd = \(String(versionMin.cmd, radix: 0x10, uppercase: true))")
        }
    }

    init(buildVersion: build_version_command) {
        switch buildVersion.platform {
        case UInt32(PLATFORM_IOS):
            self = .ios
        case UInt32(PLATFORM_MACOS):
            self = .macos
        case UInt32(PLATFORM_IOSSIMULATOR):
            self = .ios
        case UInt32(PLATFORM_IOSMAC):
            self = .macos
        default:
            fatalError("unsupported build_version_command.platform = \(String(buildVersion.platform, uppercase: true))")
        }
    }
}

private extension Mach.Segment {
    init(segment: segment_command_64, sections: [section_64]) {
        name = segment.name
        vmRange = Range(offset: segment.vmaddr, count: segment.vmsize)
        fileRange = Range(offset: segment.fileoff, count: segment.filesize)
        self.sections = sections.map { Mach.Section($0) }
    }

    init(segment: segment_command, sections: [section]) {
        name = segment.name
        vmRange = Range(offset: UInt64(segment.vmaddr), count: UInt64(segment.vmsize))
        fileRange = Range(offset: UInt64(segment.fileoff), count: UInt64(segment.filesize))
        self.sections = sections.map { Mach.Section($0) }
    }
}

private extension Mach.Section {
    init(_ section: section_64) {
        name = section.name
        range = Range(offset: UInt64(section.offset), count: section.size)
    }

    init(_ section: section) {
        name = section.name
        range = Range(offset: UInt64(section.offset), count: UInt64(section.size))
    }
}

private extension Mach.Symtab {
    init(_ symtab: symtab_command) {
        offser = UInt64(symtab.symoff)
        numberOfSymbols = UInt64(symtab.nsyms)
        stringTableRange = Range(offset: UInt64(symtab.stroff), count: UInt64(symtab.strsize))
    }
}

private extension Mach.DyldInfo {
    init(_ dyld_info: dyld_info_command) {
        bind = Range(offset: UInt64(dyld_info.bind_off), count: UInt64(dyld_info.bind_size))
        lazyBind = Range(offset: UInt64(dyld_info.lazy_bind_off), count: UInt64(dyld_info.lazy_bind_size))
        weakBind = Range(offset: UInt64(dyld_info.weak_bind_off), count: UInt64(dyld_info.weak_bind_size))
        exportRange = Range(offset: UInt64(dyld_info.export_off), count: UInt64(dyld_info.export_size))
    }
}

private extension URL {
    var platform: Mach.Platform? {
        return path.hasPrefix(Paths.iosRuntimeRoot)
            ? .ios
            : nil
    }
}
