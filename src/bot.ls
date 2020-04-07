{ Bus } = require (if process.env.CULTNET_LIVE is \true then \@cultnet/bus/src/bus else \@cultnet/bus)

export Bot = { message, pattern, command, reply }

function message subscriber
  Bus.receive \event \message \* (msg) ->
    if not msg.is-mine then subscriber msg

function pattern p, subscriber
  message ->
    pmatch = p.exec it.text
    if pmatch then subscriber it, pmatch.slice 1

function command p, subscriber
  pattern = "^" + p.replace(/<[^\s]+(\.\.\.)?>/g, (m) ->
    if m.ends-with "...>" then "([^\\n]+)"
    else "([^\\s]+)"
  ).replace(/\ /g, "\\s+") + "$"
  regex = new RegExp pattern, \i
  message ->
    pmatch = regex.exec it.text
    if pmatch then subscriber it, pmatch.slice 1

function reply msg, text
  Bus.send \action \message msg.protocol, { target: msg.source, text }
