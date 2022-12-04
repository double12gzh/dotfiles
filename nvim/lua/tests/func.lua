vim.ui.select({ 'tabs', 'spaces' }, {
  prompt = 'Select tabs or spaces:',
  format_item = function(item)
    return 'I\'d like to choose ' .. item
  end,
}, function(choice)
  print(choice)
end)

vim.ui.input({ prompt = 'Enter value for shiftwidth: ' }, function(input)
  print(input)
end)
