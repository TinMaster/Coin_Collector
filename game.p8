pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

coins = {}
enemies = {}
bullets = {}

--Worked 
function create_player()
	local p = {}
	p.x = 64
	p.y = 64
	p.score = 0
	p.highscore = 0
	p.health = 3
	p.iframe = 0
	p.fire = true
	p.sp = 1
	p.alive = true
	p.cm = true
	p.cw = true
	
	local time = 10
	--movement/update function
	p.update = function()
		local lx = p.x
		local ly = p.y
		
		if(btn(⬅️)) or btn(0,1) then
			p.x -= 1
		end
		if(btn(➡️)) or btn(1,1) then
			p.x += 1
		end
		if(btn(⬆️)) or btn(2,1) then
			p.y -= 1 
		end
		if(btn(⬇️)) or btn(3,1) then
			p.y += 1
		end
		
		if(cmap(p)) then
			p.x = lx
			p.y = ly
		end
		

		if(stat(34) == 1 ) and p.fire then
			--cursor object = c
			bullet = create_bullet(p.x, p.y)
			
			angle = atan2((c.x - p.x),(c.y - p.y)) 
			
			bullet.dx = bullet.speed * cos(angle)
			bullet.dy = bullet.speed * sin(angle)
			p.fire = false
			time = 10
			sfx(4)
			add(bullets,bullet)

		end
		
		if p.iframe > 0 then
			p.iframe -= 1
		end
		
		if p.health == 0 then
			p.alive = false
		end

		if time > 0 then
			time -= 1
		end
		if not p.fire and time == 0 then
			p.fire = true
		end 

	end
	
	p.draw = function()
		palt(0,false)		
		spr(p.sp, p.x, p.y )
		pal(0,true) --toggle opacity
	end
	
	return p
end

function create_enemy()
	local e = random_cords() 
	
	add(enemies, e)
	
	e.dx = 0
	e.dy = 0
	e.tick = rnd(10,15)
	e.d = 0

	e.draw = function()
		palt(0,false)
		spr(23, e.x, e.y)
	end
	
	e.update = function()
		--good enough
		e.tick -= 1

		if e.tick <= 0 then

			if(player.x < e.x) e.x -= 1
			if(player.x > e.x) e.x += 1
			if(player.y < e.y) e.y -= 1
			if(player.y > e.y) e.y += 1
			
			e.tick = rnd(10,15)

		end	
	end

	return e
	
end

function create_coin(x,y)
	local c = {}
	c.x = x
	c.y = y
	add(coins,c)
	
	c.draw = function(this)
		spr(19,this.x, this.y)
	end
	
	return c

end

function create_cursor()
	local p = {}
	p.x = stat(32) - 1
	p.y = stat(33) - 1
	
	p.update = function()
		p.x = stat(32) - 1
		p.y = stat(33) - 1
	end

	p.draw = function()
		spr(5, p.x, p.y)
	end
	return p
end

function create_bullet(x,y)
	local b = {}
	b.x = x
	b.y = y
	b.dx = 0
	b.dy = 0
	b.speed = 6
	b.sp = 6

	b.update = function()
		b.x = b.x + b.dx
		b.y = b.y + b.dy
	end

	b.draw = function()
		spr(6,b.x, b.y)
	end
	return b
end
--helper functions
function generate_coins()
	for i = 1, 5 + lvl do
		create_coin()
	end
end

function generate_enemies()
	for i = 1, 10 + lvl do	
		create_enemy()
	end
end

function random_cords()
	local r = {}
	
	local x = flr(rnd(112) + 8) 
	local y = flr(rnd(104) + 16) 
	 
	r.x = x - (x%8)
	r.y = y - (y%8) 
		
	return r

end

--collision--
function cmap(o)
  local ct=false
  local cb=false

  -- if colliding with map tiles
  if(o.cm) then
    local x1=o.x/8
    local y1=o.y/8
    local x2=(o.x+7)/8
    local y2=(o.y+7)/8
    local a=fget(mget(x1,y1),0)
    local b=fget(mget(x1,y2),0)
    local c=fget(mget(x2,y2),0)
    local d=fget(mget(x2,y1),0)
    ct=a or b or c or d
   end
   -- if colliding world bounds
   if(o.cw) then
     cb=(o.x<0 or o.x+8>126 or
           o.y<0 or o.y+8>126)
   end

  return ct or cb
end

function solid(obj)
	local tilex = (obj.x - (obj.x % 8)) / 8 
	local tiley = (obj.y - (obj.y % 8)) / 8
	if fget(mget(tilex, tiley),0) then
		return true
	else
		return false
	end
end

function col(x1,x2,xw,xh,y1,y2,yw,yh)
 	if	(x1> y1 + yw) then
 	 return false
	 end
	 if(x1 + xw < y1) then
 	 return false
	 end
	 if(x2 > y2 + yh) then
 	 return false
	 end
	 if(xh + x2 < y2) then
 	 return false
 	end
	 return true
 end

function col_things(o,objs)
	for obj in all(objs) do
	 	return col(o.x, o.y, 8,8, obj.x,obj.y,8,8)
		--if o.x == obj.x and o.y == obj.y then
		--	return true
		--end
	end
	
	return false
end

--todo move to indivual update functions probably
function chk_collision()
	
	for coin in all(coins) do
		if col(player.x, player.y,	4,4, coin.x, coin.y, 4, 4) then
		 	del(coins,coin)
				sfx(1)
				player.score += 10				
		end
	end
	
	for enemy in all(enemies) do
			if col(player.x, player.y,	4,4, enemy.x, enemy.y, 6, 6) and player.iframe == 0 then
				player.health -= 1
				sfx(2,2)
				player.iframe = 30
				--kills itself upon impact
				create_coin(enemy.x,enemy.y)
				del(enemies,enemy)
			end

			for bullet in all(bullets) do
				if col(bullet.x, bullet.y, 4, 4, enemy.x, enemy.y, 4,4) then
					if(flr(rnd(20)) > 15) create_coin(enemy.x, enemy.y)
					del(bullets,bullet)
					del(enemies,enemy)
					sfx(3)
					player.score += 1
				
				end
			end
	end

	for bullet in all(bullets) do
		if cmap(bullet) then
			del(bullets, bullet)
		end
	end

	--[[if(#coins == 0) then
		lvl += 1
		generate_coins()
	end--]] 
	--todo make enemies drop coins instead?

	if(player.alive == false) then
		gameover_init()
	end
	if(#enemies == 0) then
		lvl += 1
		generate_enemies()
	end

end

function debug()
	color(2)
	print("x: "..player.x,0,10)
	print("y: "..player.y,0,16)
 	print("tile x: ".. (player.x - (player.x % 8)) / 8,0,22)
	print("tile y: ".. (player.y - (player.y % 8)) / 8,0,28)
	print(cmap(player.x,player.y),0,34)
	print("enemies: "..#enemies,0,40)	
	print("coins: "..#coins,0,46)
	print("memory: "..stat(0),0,52)
end

function draw_bar()
	local x1 = 0
	for i = 1, 3 do
		spr(22,x1,0)
		x1+=8
	end

	local x = 0
	for i = 1, player.health do
		spr(21,x,0)
		x+=8
	end
	color(7)
	print("score:"..player.score,28,1)
	print("level:"..lvl,92,1)
end

function _init()
	poke(0x5f2d, 1)
	lvl = 1
	c = create_cursor()
	player = create_player()
    generate_enemies()
end


function _update()
	player.update()
	c.update()
	chk_collision() --should move stuff to their own update function
	for enemy in all(enemies) do
		enemy.update()
	end
	
	for bullet in all(bullets) do
		bullet.update()
	end
end

function _draw()
	cls()
	map(0,0)
	palt(0,true)
	--different code same thing
	foreach(coins, function(obj)
		obj.draw(obj)
	end)
	
	for bullet in all(bullets) do
		bullet.draw()
	end
	for enemy in all(enemies) do
		enemy.draw()
	end		
	player.draw()
	draw_bar()
	--debug()
	palt(0,true)
	c.draw()
end

--gameover screen


function gameover_init()
	_update = gameover_update
	_draw = gameover_draw
	pointer = create_cursor()
end

function gameover_update()
	pointer.update()

end

function gameover_draw()	
	cls()
	map(0,0)
	color(2)
	rectfill(8,16,119,119)
	
	color(7)
	printc("game over", 32)
	printc("hiscore:"..player.highscore,40)
	printc("score:"..player.score, 56)
	printc("retry",72)
	printc("quit",80)
	pointer.draw()
		
end

function printc(str,y)
	print(str, 64 - (#str*2),y)
end
--menu screen
function menu_init()
	_update = menu_update()
	_draw = menu_draw()
end

function menu_update()
end

function memu_draw()
end

__gfx__
00000000c777777c00777a00c777777cc777777c0008000000000000000880000055550000000000000000000000000000000000000000000000000000000000
000000007ccc0c0707777a707cccccc77cccccc70888880000000000000088000500005000000000000000000000000000000000000000000000000000000000
000000007ccc0c0770777a077ccc0c077cccccc70800080000000000000008805000000500000000000000000000000000000000000000000000000000000000
000000007ccc0c07700000077cccccc77cccccc78808088000099000888888885000000500000000000000000000000000000000000000000000000000000000
000000007cccccc7070005707cccccc77cccccc70800080000099000888888885000000500000000000000000000000000000000000000000000000000000000
000000007cccccc7000005007cccccc77cccccc70888880000000000000008805000000500000000000000000000000000000000000000000000000000000000
000000007cccccc7000005007cccccc77cccccc70008000000000000000088000500005000000000000000000000000000000000000000000000000000000000
00000000c777777c00000000c777777cc777777c0000000000000000000880000055550000000000000000000000000000000000000000000000000000000000
66666166dddddddd11aaaa110aa00000188888810880880005505500355555530000000000000000000000000000000000000000000000000000000000000000
66666166dddddddd1a997aa1aaaa0000118888118888888050050050533303050000000000000000000000000000000000000000000000000000000000000000
66666166dddddddda9977aaaaaaa0000111881118888888050000050533303050000000000000000000000000000000000000000000000000000000000000000
11111111dddddddda77aaaaaaaaa0000111881118888888050000050533303050000000000000000000000000000000000000000000000000000000000000000
66616666ddddddddaaaaa77aaaaa0000111881110888880005000500533333350000000000000000000000000000000000000000000000000000000000000000
66616666ddddddddaaaa799a0aa00000111881110088800000505000533333350000000000000000000000000000000000000000000000000000000000000000
66616666dddddddd1aa799a100000000111881110008000000050000533333350000000000000000000000000000000000000000000000000000000000000000
11111111dddddddd11aaaa1100000000111881110000000000000000355555530000000000000000000000000000000000000000000000000000000000000000
00000000dddddddd000000000aa00000888888800880880000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000dddddddd00000000aaaa00008888888087e8e88000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000dddddddd00000000aaaa0000888888808ee8888000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000dddddddd00000000aaaa0000888888808888888000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000dddddddd00000000aaaa0000888888800888880000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000dddddddd000000000aa00000888888800088800000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000dddddddd0000000000000000888888800008000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000dddddddd0000000000000000888888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000aaaaaa0000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000a0000a0000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000a0aa0a0000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000a0aa0a0000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000a0000a0000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000aaaaaa0000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000010000000000000000000000000001000000010000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1011111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1011111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1011111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1011111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1011111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1011111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1011111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1011111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1011111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1011111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1011111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1011111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1011111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f003f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00003f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00003f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00003f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00003f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0003000015050140500f0500c0500a05008050050500305003300013001a50015500115000e5000a50008500002000020000200002000020000200002000020000200002002b0000020000200002000020000200
000300002a5352f53533535385353d5353f535106051060510605106051060511605126051260512605126051260511605116052010521105231052410526105281052a1050f4052500525005054050f50511205
000600002235321350203531d35018355123500c3530a3500730014304143001430014305000002b60500000183030c000240030000030605000000c1033c305396003b604396000130001305123001230513300
00030000235501f5501855014550105500a550075500655003300013001a50015500115000e5000a50008500002000020000200002000020000200002000020000200002002b0000020000200002000020000200
000600001f6150d61013615176121f6151f61217612106151f614017050e70701705217022170521702217071f3051b7021b5071b20518102164051b302167051350213107132051140211707113050f50211105
001000000c70618506187060c50518705185050c705185050c705187050c50518705187050c505187051850518705247052450518705245051870524505247051870524505187052450524705185052470524505
00100000184061b106185061b206184061b3061d5061b706181061d206184061d306187061d5061f1061d4061a2061d7061f3061d5061a4061d106222061d7061a5061f306224061f1061d2061f7062250624306
001000001810018100181001810000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
001000000c105182050c405185051b106182051d4051f5050c105182050c405185051b105182051d4051f5050c105182070c105182050c105182050c105182050c106182060c1061820618106242063010624206
00100000187002470018700247001f70024700227002b70030707297072b707247071d707247071d7071f707185002440018200241001f50024400222002b10030506355062b50629506185061d506135060c506
__music__
05 01414141
00 01020541
00 01020341
00 01020341
00 01020441
00 01020341
00 08414141
00 08094141
00 01020809
00 01020809
00 01024106
02 01020809
00 41414141
00 41414141
00 41414141
00 41414141
00 41414141
00 41414141
00 41414141
00 41414141
00 41414141
00 41414141
00 41414141
00 41414141
00 41414141
00 41414141
00 41414141
00 41414141
00 41414141
00 41414141
00 41414141
00 41414141
00 41414141
00 41414141
00 41414141
00 41414141
00 41414141
00 41414141
00 41414141
00 41414141
00 41414141
00 41414141
00 41414141
00 41414141
00 41414141
00 41414141
00 41414141
00 41414141
00 41414141
00 41414141
00 41414141
00 41414141
00 41414141
00 41414141
00 41414141
00 41414141
00 41414141
00 41414141
00 41414141
00 41414141
00 41414141
00 41414141
00 41414141
00 41414141

