* TODO [2015-01-03 Sat] dsah: perl compiler: Replace smartmatch because of its inconsistent behavior

  C<<$data ~~ ["x", 1]>> will do string comparison, while C<<$data ~~ [1, "x"]>>
  or even C<<$data ~~ ["1", "x"]>> will do a numeric comparison.

* IDEA [2014-04-29 Sel] dsah: date: support format ISO8601 ("2014-04-29T01:02:03")

  - ingat, format ISO8601 ini ada banyak lho variannya... kita pilih mensupport
    satu atau beberapa varian aja.
  - ntar kalo butuh deh, ke depannya kemungkinan sih akan butuh

* IDEA [2014-04-29 Sel] dsah: plc: return normalized datetime utk tipe date?

  - mempermudah fungsi agar langsung dapet
  - optimize juga, gak usah calculate coerce_date() 2x.
  - fungsi dapat melakukan gini: $date = $wrap_result{date} //
    coerce_date($args{date}); jadi bisa avoid calculate 2x tapi juga jika fungsi
    tidak diwrap masih bisa jalan.

* BUG [2014-06-20 Fri] dsah: gagal/salah dalam mengeset locale

  ada pesan error ini di log periahs:
  

      [pid 28341] [2014/06/20 09:21:51] Data/Sah/Lang/C cannot be found, falling back to en_US
  
  kayaknya cara ngeset locale salah, jadi nama package terbawa gitu.

* BUG [2014-04-29 Sel] dsah: jsc: hasil compile error jika debug=1 [#E]

  ada 'function() { ... }' lagi ngewrap 'function (data) { ... }' dan jadi syntax
  error.

* TODO [2014-04-27 Sun] dsah: use Sah-Schema-Sah untuk determine which prop contains another schema, so it can offer recursive normalization

  - agak ribet, karena clause2x yang mana aja tergantung dari tipenya.
