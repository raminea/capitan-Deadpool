do

function run(msg, matches)
  return '' .. matches[1] .. ' ' .. matches[2] .. ''
end

return {
  description = "Says anything to someone", 
  usage = "say [text] to [name]",
  patterns = {
    "^[/!#][Ss][Aa][Yy] (.*) [Tt][Oo] (.*)$",
    "^[Ss][Aa][Yy] (.*) [Tt][Oo] (.*)$"
  }, 
  run = run 
}

end
