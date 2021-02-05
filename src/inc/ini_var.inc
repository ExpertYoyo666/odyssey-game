PROC try_again
  mov [v_min] , 7
  mov [v_max] , -7
  mov [character_velocity] , 0
  mov [character_loc_x] , 20
  mov [character_loc_y] , 50
  mov [character_width] , 10h
  mov [character_height] , 10h
  mov [offset_character] , 0
  mov [offset_jump_process] , 0
  mov [time_counter] , 0
  mov [sec_counter]  , 0
  mov [time_since_start] , 0
  mov [reminder] , 0
  mov [result_min] , 0
  mov [result_sec] , 0
  ret
ENDP try_again
