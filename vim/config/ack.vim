" Sets the :Ack command to use 'the silver searcher'
let g:ackprg = 'ag --nogroup --nocolor --column'

command -nargs=* G :Ack "<args>"
command -nargs=* F :AckFile "<args>"
