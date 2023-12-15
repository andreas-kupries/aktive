
# DSL

```
operator name {

	 <type>      PARAM ...
	 <type>? VAL PARAM ...

	 state -fields {
 	 	C structure fields // image client data
	 } -setup {
		// (info)	IN  // hidden
		// param	(info) IN (see declared params)
		// srcs		(info) IN []image
		// domain	(info) IN geometry
		// state	(info) OUT image state
		// meta		OUT meta data
	 } -cleanup {
		// state	IN image state
	 }

	 pixels -fields {
	 	C structure fields // region client data
	 } -setup {
 		// (info)	IN  // hidden
		// param	(info) IN (see declared params)
		// srcs		(info) IN []image
		// istate	(info) IN s.a. fields
		// state	(info) OUT region state
	 } -cleanup {
		// state	IN region state
	 } {
		// (info)	IN  // hidden
		// param	(info) IN (see declared params)
		// srcs		(info) IN []region
		// state	(info) IN region state
		// istate	(info) IN image state
		// domain	(info) IN image geometry
		// request	IN rectangle to compute pixels for
		// dst		IN destination rect in block
		// block	IN pixel storage
	 }

	 support {
		// 
	 }

	 return TYPE {
		// 
	 }
}
```
