# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- #
# Void°Doctrine VK observer v0.13   #
# Developed in 2018 by V.A. Guevara #
# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- #

import os, marshal, vkapi, streams, strformat, times, parseutils, strutils, tables, times, parsecfg, terminal, encodings
import parseopt, sugar, random, threadpool, locks, sets, httpclient
when sizeof(int) == 4: {.link: "res/void86.res".}
elif sizeof(int) == 8: {.link: "res/void64.res".}
{.experimental.}
{.this: self.}

#.{ [Classes]
when not defined(Meta):
    type IFace  = ref object {.inheritable.}
    method log(self: IFace, info: string, channel: string) {.base gcsafe.} = discard
    const mottos = [
        "From below it devours",
        "Trust is a weakness",
        "Watch your steps",
        ]

    # --Methods goes here:
    template either[T](flag: bool, true_val: T, false_val: T): T =
        if flag: true_val else: false_val

    proc account(num: int, countable: string = ""): string {.inline.} =
        result = either(num == 0, "No", $num)
        if countable != "": result &= fmt" {countable}" & either(num == 1, "", "s")

    proc errinfo(): auto {.inline.} =
        fmt"{getCurrentExceptionMsg()}\n{getStackTrace()}".replace("""\n""", "\n")

    proc dequote(trash: JsonNode): auto {.inline.} =
        ($trash).strip(true, true, {'"'})

    proc openFileStream(filename: string, mode = fmRead, bufSize = -1): auto = # Compatibility, huh ?
        result = newFileStream(filename, mode, bufsize)
        if result.isNil: raise new(ref IOError)

    template shadow(path): auto =
        getTempDir().joinPath(path.extractFilename() & ".tmp")

    proc unshadow(path: string) =
        let backup = path & ".bak"
        try:
            if path.fileExists(): # If there is something to backup.
                discard backup.tryRemoveFile()
                path.moveFile(backup)
            # Actual unshadowing.
            path.shadow().moveFile(path)
            discard backup.tryRemoveFile()
        except: # Restoring old copy.
            if backup.fileExists():
                discard path.tryRemoveFile()
                backup.moveFile(path)
# -------------------- #
when not defined(CUI):
    type CUI = ref object of IFace
        conv:   EncodingConverter
    const CUI_channels = {
        "meta":     (fgGreen, styleBright, ""),
        "motto":    (fgBlack, styleDim, ""),
        "io":       (fgYellow, styleBright, ""),
        "net":      (fgYellow, styleDim, ""),
        "fail":     (fgRed, styleBright, ""),
        "fault":    (fgRed, styleDim, ""),
        "foreword": (fgCyan, styleBright, "┌"),
        "remark":   (fgBlack, styleBright, "├>"),
        "unremark": (fgBlack, styleBright, "├■"),
        "changes":  (fgMagenta, styleBright, "│"),
        "afterword":(fgCyan, styleDim, "└"),
        }.toTable

    # --Methods goes here:
    proc destroyCUI(self: auto) =
        self.conv.close()
        resetAttributes()        
        3000.sleep()

    proc init(self: type CUI): CUI =
        new(result, destroyCUI)
        result.conv = encodings.open("CP866", "UTF-8")
        result.log """  # -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- #
                        # Void°Doctrine VK observer v0.13   #
                        # Developed in 2018 by V.A. Guevara #
                        # -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- #""".replace("  ", ""), "meta"
        result.log mottos.rand(), "motto"
        when defined(windows):
            proc set_console_title(title: WideCString): cint 
                {.stdcall, dynlib: "kernel32", importc: "SetConsoleTitleW".}
            discard "Void°Doctrine".newWideCString.set_console_title

    method log(self: CUI, info: string, channel: string) =
        let (color, style, prefix) = CUI_channels[channel]
        styledEcho fgWhite, styleBright, conv.convert prefix, color, style, conv.convert info
# -------------------- #
when not defined(CRC32):
    type CRC32 = ref object
        value: uint32
    const CRC32_table = block:
        var result: array[0..255, uint32]
        for i in 0..255:
            var rem = i.uint32
            for j in 0..7:
                if (rem and 1) > 0'u32: rem = (rem shr 1) xor 0xedb88320.uint32
                else: rem = rem shr 1
            result[i] = rem
        result

    # --Methods goes here:
    proc init(kind: type CRC32): CRC32 = 
        const init_CRC32 = uint32(-1)
        CRC32(value: init_CRC32)

    proc recalc(self: CRC32, c: char) =
        value = (value shr 8) xor CRC32_table[(value and 0xff) xor c.ord.uint32]

    proc from_url(self: type CRC32, url: string): uint32 =
        try:
            let feed = newHttpClient().get(url).bodyStream
            let accum = CRC32.init
            while not feed.atEnd: accum.recalc feed.readChar
            return accum.value
        except: return 0
# -------------------- #
when not defined(History):
    type History = ref object
        path:   string
        data:   Config

    # --Methods goes here:
    proc init(self: type History, path: string): History =
        History(path: path, data: try: path.loadConfig() except: newConfig())

    proc register(self: History, sect: string, feed: seq[string]): auto {.discardable inline.} =
        # Init setup.
        var idx = 0
        # Main rewriting.
        for entry in feed:
            while true:
                idx.inc
                let key = getTime().local.format("dd/MM/yyyy'•'HH'⫶'mm'⫶'ss") & 
                    either(idx > 1 or feed.len > 1, fmt"│{idx}", "")
                if data.getSectionValue(sect, key) == "":
                    data.setSectionKey(sect, key, entry)
                    break
        # Finalization.
        data.writeConfig(path.shadow())
        path.unshadow()
        return self        
# -------------------- #
when not defined(User):
    type User = object
        id:          Natural
        timestamp:  Time
        name:       tuple[first, last: string]
        photo_crc:  uint32
        disabled, status, photo: string
        friends, followers, following, publics: seq[Natural]
    const locale = "ru"

    # --Methods goes here:
    proc load(id: Positive, vk: VKApi, brief = false): User =
        # Service def.
        proc interim(json: JsonNode, Δ = ""): auto = either(Δ.len > 0, json[Δ], json)
        template get_all(feed: auto, max: Natural, Δ = ""): seq[Natural] =            
            var 
                storage: seq[Natural]
                count = vk.request(feed, {"user_id": $id, "count": $1}.toApi).interim(Δ)["count"].dequote.parseInt
                offset = 0
            while offset < count:
                 for x in vk.request(feed,{"user_id": $id,"count": $max,"offset": $offset}.toApi).interim(Δ)["items"]:
                     storage.add x.dequote.parseInt
                     offset.inc()
            storage
        # Brief parsing.
        result      = User(id: id, timestamp: getTime())
        let data    = vk@users.get(user_id=id, fields="status, photo_max", lang=locale)[0]
        result.name = (first: data["first_name"].dequote, last: data["last_name"].dequote)
        if "deactivated" in data: result.disabled = data["deactivated"].dequote
        if brief or result.disabled.len > 0: return result
        # Additional parsing.
        result.status       = data["status"].dequote
        result.photo        = data["photo_max"].dequote
        result.friends      = "friends.get".get_all(5000)
        result.followers    = "users.getFollowers".get_all(1000)
        result.publics      = "users.getSubscriptions".get_all(200, "groups")
        result.following    = "users.getSubscriptions".get_all(200, "users")
        
    proc reload(path: string): User =
        let stream = path.openFileStream(fmRead)
        stream.load(result)
        stream.close()

    proc save(self: User, path: string): auto {.discardable.} =
        # Init setup.
        let stream   = path.shadow().openFileStream(fmWrite)
        # Failproof data saving.
        stream.store(self)
        stream.close()
        # Finalization.
        path.unshadow()
        return self

    proc get_pub(id: Natural, vk: VKApi): auto {.inline.} =
        return fmt"""vk.com/public{id} [{vk@groups.getById(group_id=id, lang=locale)[0]["name"].dequote}]"""

    proc `stamp`(self: User): auto {.inline.} = timestamp.local.format("dd/MM/yyyy '<'HH:mm:ss'>'")
    proc `$`(self: User): auto {.inline.} =
        fmt"vk.com/id{id} [{name.first} {name.last}]" & either(disabled.len > 0, fmt" >> {disabled}", "")
# -------------------- #
when not defined(VoidDoctrine):
    type VoidDoctrine = ref object
        token:  string
        ui:     IFace
    var blocker: Lock
    const archive = (dir: "archive", ext: "json")
    proc vk(self: VoidDoctrine): auto {.inline.} = newVKApi(token)    

    # --Methods goes here:
    proc init(kind: type VoidDoctrine, ui: IFace, token: string): VoidDoctrine =
        try:
            result = VoidDoctrine(token: token, ui: ui)
            discard result.vk.request("users.get", {"user_id": "1"}.toApi)
            ui.log fmt"Token digested: {token}", "net"
            setCurrentDir getAppDir()
            if not archive.dir.dirExists: archive.dir.createDir
            blocker.initLock
        except: 
            result.token = ""
            ui.log fmt"Startup fault // {errinfo()}", "fault"

    proc log(self: VoidDoctrine, info: auto, channel = "fault"): auto {.discardable gcsafe inline.} =
        ui.log $info, channel; return self

    proc log(self: VoidDoctrine, stack: seq[tuple[info, channel: string]]) =
        for entry in stack: log(entry.info, entry.channel)

    proc diff[T](prev: seq[T], current: seq[T]): auto =
        result = newTable[T, bool]()
        for entry in prev: result[entry] = false
        for entry in current:
            if entry in result: result.del(entry) else: result[entry] = true

    proc inspect(self: VoidDoctrine, id: Natural, dest_shared: ptr History): auto {.gcsafe discardable.} =
        # Service defs.
        template mem(info: string, channel: string) = uibuffer.add (info, channel)
        template reg(info: string)                  = histbuffer.add info
        template report(field: untyped, countable: string, name: string, handler: auto): auto =
            mem (" $# found" % user.field.len.account(countable) & # Mandatory report.
                either(user.field.len != prev.field.len, " versus former " & $prev.field.len, ".")), "remark"
            for id, added in prev.field.diff(user.field).pairs:
                let msg = added.either("+$# added$#", "-$# removed$#") % [name, handler(id)]
                mem msg, "changes"
                reg msg
                changes.inc()
        template report(was: untyped, now: untyped, name: string) =
            if now != was:
                mem "~$# was changed from $#" % [name, $was], "changes"
                reg "~$# changed to: $#" % [name, $now]
                changes.inc()
        template report(field: untyped, name: string) = report(prev.field, user.field, name)
        template show(feed: string, rem: string) = 
            if feed.len == 0: mem "°No $# data available°" % rem, "unremark" else: mem feed, "remark"
        # Initial setup.
        try: # Master handler.
            var
                uibuffer:   seq[tuple[info: string, channel: string]]
                histbuffer: seq[string]
                changes     = 0
                dest        = cast[History](dest_shared)
                user: User  = (try: id.load(self.vk) except: User(status: getCurrentExceptionMsg()))
            let path = fmt"{archive.dir}/{id}.{archive.ext}"
            if user.disabled.len > 0: mem fmt"Unable to access userdata for {user}", "fail" 
            elif user.id > 0: # Actual parsing goes here.
                let prev = (try: path.reload() except: User())        
                mem fmt"Acquired data for {user}:", "foreword"
                # Status out.
                user.status.show "status"
                if prev.id > 0:
                    # Auxilary closures.
                    let fetch_user = (id: Natural) => fmt": {id.load(self.vk, true)}"
                    let fetch_group = (id: Natural) => fmt": {id.get_pub(self.vk)}"            
                    # Report blocks.
                    report prev.name.first, user.name.first,    "First name"
                    report prev.name.last,  user.name.last,     "Last name"
                    report status,      "Status"
                    report friends,     "friend",       "Friend",       fetch_user
                    report following,   "user sub",     "Subscription", fetch_user
                    report followers,   "subscriber",   "Subscriber",   fetch_user
                    report publics,     "public sub",   "Public",       fetch_group
                    # Photo CRC32 comparsion.
                    user.photo.show     "photo"
                    if user.photo != prev.photo:
                        user.photo_crc = CRC32.from_url(user.photo)
                        if user.photo_crc != prev.photo_crc: report photo, "Photo"
                    else: user.photo_crc = prev.photo_crc
                    # Reporting in.
                    mem fmt""" {changes.account("change")} detected since {prev.stamp}""", "remark"
                else: mem fmt"*No previous entry was found to compare, diff unavailable.", "remark"
                # Fnalization.
                user.save(path)
                mem fmt"User data serialized as {path}", "afterword"
            else: mem fmt"Unable to access userdata for vk.com/id{id} << {user.status}", "fail"
            # Sync final.
            withLock(blocker):
                log uibuffer
                if histbuffer.len > 0: dest.register($user, histbuffer)
        except: log fmt"Inspector fault // {errinfo()}", "fault"
        return self

    proc parse(self: VoidDoctrine, entry: TaintedString): Natural {.inline.} =
        if parseInt(entry, result) > 0: return result
        return (try: self.vk@users.get(user_ids=entry)[0]["id"].dequote.parseInt except: 0)

    proc feed(self: VoidDoctrine, fname: string): auto {.discardable.} =
        # Init setup.
        if token.len == 0: return log(fmt"Unable to process without VK connection.", "fail")
        let path    = changeFileExt(fname, "hist")
        var dest    = History.init(path)
        var pages: HashSet[Natural]
        log fmt"Parsing {fname} => {dest.path}...", "io"
        # Actual parsing.
        try:
            pages.init(2)
            for entry in fname.lines:
                let id = parse(entry)
                if id in pages: log fmt"Duplicate entry encountered (vk.com/id{id}): {entry}", "fault"
                elif id > 0:    discard spawn inspect(id, cast[ptr History](dest)); pages.incl id
                else:           log fmt"Invalid entry encountered: {entry}", "fault"
            sync()
            log "...Parsing complete ($#)" % pages.len.account("page"), "io"
        except: log fmt"Feeder fault // {errinfo()}", "fault"
        return self
#.}

# ==Main code==
when isMainModule:
    proc main =
        var token   = "5b9fad885b9fad885b9fad88045bd2026155b9f5b9fad8800c4307de742fc28e17da572"
        var feeder  = "feed.txt"
        for kind, key, val in getopt():
            case kind:
                of cmdArgument: feeder = key
                of cmdLongOption, cmdShortOption:
                    case key
                        of "token", "t": token = val
                of cmdEnd: assert(false)
        VoidDoctrine.init(CUI.init, token).feed(feeder).ui = nil
    GC_disableMarkAndSweep()
    main()
    GC_fullCollect()