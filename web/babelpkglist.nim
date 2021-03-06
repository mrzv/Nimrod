import base64, strutils, json, htmlgen, dom, algorithm

type
  TData = object
    content {.importc.}: cstring

proc decodeContent(content: string): string =
  result = ""
  for line in content.splitLines:
    if line != "":
      result.add decode(line)

proc contains(x: seq[PJSonNode], s: string): bool =
  for i in x:
    assert i.kind == JString
    if i.str == s: return true

proc processContent(content: string) =
  var jsonDoc = parseJson(content)
  assert jsonDoc.kind == JArray
  var jsonArr = jsonDoc.elems

  jsonArr.sort do (x, y: PJsonNode) -> int:
    system.cmp(x["name"].str, y["name"].str)

  var
    officialList = ""
    officialCount = 0
    unofficialList = ""
    unofficialCount = 0

  for pkg in jsonArr:
    assert pkg.kind == JObject
    let pkgWeb =
      if pkg.hasKey("web"): pkg["web"].str
      else: pkg["url"].str
    let listItem = li(a(href=pkgWeb, pkg["name"].str), " ", pkg["description"].str)
    if pkg["url"].str.startsWith("git://github.com/nimrod-code") or
       "official" in pkg["tags"].elems:
      officialCount.inc
      officialList.add listItem & "\n"
    else:
      unofficialCount.inc
      unofficialList.add listItem & "\n"

  var officialPkgListDiv = document.getElementById("officialPkgList")

  officialPkgListDiv.innerHTML.add(
    p("There are currently " & $officialCount &
      " official packages in the Babel package repository.") &
    ul(officialList)
  )

  var unofficialPkgListDiv = document.getElementById("unofficialPkgList")

  unofficialPkgListDiv.innerHTML.add(
    p("There are currently " & $unofficialCount &
      " unofficial packages in the Babel package repository.") &
    ul(unofficialList)
  )

proc gotPackageList(apiReply: TData) {.exportc.} =
  let decoded = decodeContent($apiReply.content)
  try:
    processContent(decoded)
  except:
    var officialPkgListDiv = document.getElementById("officialPkgList")
    var unofficialPkgListDiv = document.getElementById("unofficialPkgList")
    let msg = p("Unable to retrieve package list: ",
      code(getCurrentExceptionMsg()))
    officialPkgListDiv.innerHTML = msg
    unofficialPkgListDiv.innerHTML = msg
