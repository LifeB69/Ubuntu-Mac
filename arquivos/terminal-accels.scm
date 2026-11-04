; Gerado pelo Ubuntu-Mac — atalhos do xfce4-terminal no estilo Mac.
; O keyd transforma ⌘C/⌘V em Ctrl+Insert/Shift+Insert (ver arquivos/keyd-mac.conf).
; Aqui: Shift+Insert cola a ÁREA DE TRANSFERÊNCIA (o padrão colava a seleção do mouse).
; O Ctrl+C de verdade continua interrompendo o programa, como no Terminal do Mac.
(gtk_accel_path "<Actions>/terminal-window/paste-selection-alt" "")
(gtk_accel_path "<Actions>/terminal-window/paste-alt" "<Shift>Insert")
