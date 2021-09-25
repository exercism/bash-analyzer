#!/usr/bin/env ruby
#
# jq can probably do this...

require 'json'

=begin

The stdin will be `shellcheck --format=json1` output:

  {"comments": [comment_object, ...]}

A Shellcheck comment object looks like:

   {"file": "bob.sh",
    "line": 16,
    "endLine": 16,
    "column": 24,
    "endColumn": 28,
    "level": "error",
    "code": 2199,
    "message": "Arrays implicitly concatenate in [[ ]]. Use a loop (or explicit * instead of @).",
    "fix": nil}

=end

data = JSON.parse(STDIN.read)

findings = {error: {}, warning: {}, info: {}, style: {}}
count = 0

data["comments"].each do |sc_cmt|
  level = sc_cmt["level"].to_sym
  code = sc_cmt["code"]
  
  if findings.has_key? level
    count += 1
    if not findings[level].has_key? code
      findings[level][code] = {
        message: sc_cmt["message"],
        lines: []
      }
    end
    findings[level][code][:lines] << sc_cmt["line"]
  end
end

comments = []

[:error, :warning, :info, :style].each do |level|
  findings[level].keys.sort.each do |code|
    msg = findings[level][code][:message]
    lines = findings[level][code][:lines].sort.uniq
    lines_text = 
      if lines.size == 1
        "line #{lines.first}"
      else
        "lines #{lines.join(", ")}"
      end

    comment = {
      comment: "bash.shellcheck.generic",
      type: "informative", 
      params: {
        message: msg,
        code: code,
        lines: lines_text,
      }
    }
    comments << comment
  end
end

summary = 
  if findings[:error].size > 0
    "Shellcheck errors encountered"
  elsif findings[:warning].size > 0
    "Shellcheck warnings encountered"
  elsif count == 0
    "Congrats! No Shellcheck suggestions"
  else
    "Shellcheck suggestions"
  end

puts JSON.pretty_generate({
  summary: summary,
  comments: comments
})
