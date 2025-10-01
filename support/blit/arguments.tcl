# -*- mode: tcl ; fill-column: 90 -*-
## blitter - argument management

# # ## ### ##### ######## #############

namespace eval ::dsl::blit::argument {
    variable db {} ;# dict (name -> ".")
    variable known ;# dict (name -> list (default description))
    #
    # API
    #
    namespace export clear mark used is definition
    namespace ensemble create
    namespace import ::dsl::blit::system::abort
}

# # ## ### ##### ######## #############
## API implementation

proc ::dsl::blit::argument::clear {} {
    variable db {} ; return
}

proc ::dsl::blit::argument::mark {name} {
    if {![is $name]} { E "'$name' is unknown" }
    variable db
    dict set db $name .
    return
}

proc ::dsl::blit::argument::used {} {
    variable db
    lsort -dict [dict keys $db]
}

proc ::dsl::blit::argument::is {name} {
    variable known
    dict exist $known $name
}

proc ::dsl::blit::argument::definition {name} {
    variable known
    dict get $known $name
}

# # ## ### ##### ######## #############
## internal helpers

proc ::dsl::blit::argument::E {message} {
    abort "argument error: $message"
}

# # ## ### ##### ######## #############

namespace eval ::dsl::blit::argument {
    # name -> list (default description)
    variable known {
	AH      {dst->height		{Destination area height}}
	AW      {dst->width		{Destination area width}}
	AX      {dst->x			{Destination area start column}}
	AY      {dst->y			{Destination area start row}}
	DD      {block->domain.depth	{Destination block depth}}
	DH      {block->domain.height	{Destination block height}}
	DST     {block->pixel		{Destination pixel memory}}
	DSTCAP  {block->used		{Destination capacity}}
	DW      {block->domain.width	{Destination block width}}
	PHASE0  {{}                     {Initial phase for fractional stepping}}
	PHASE1  {{}                     {Initial phase for fractional stepping}}
	PHASE2  {{}                     {Initial phase for fractional stepping}}
	S0D     {srca->domain.depth	{Source 1 depth}}
	S0H     {srca->domain.height	{Source 1 height}}
	S0W     {srca->domain.width     {Source 1 width}}
	S1D     {srcb->domain.depth	{Source 2 depth}}
	S1H     {srcb->domain.height	{Source 2 height}}
	S1W     {srcb->domain.width     {Source 2 width}}
	SD      {src->domain.depth	{Source block depth}}
	SH      {src->domain.height	{Source block height}}
	SRC     {src->pixel		{Source pixel memory}}
	SRC0    {srca->pixel		{Source 1 pixel memory}}
	SRC0CAP {srca->used		{Source 1 capacity}}
	SRC1    {srcb->pixel		{Source 2 pixel memory}}
	SRC1CAP {srcb->used		{Source 2 capacity}}
	SRCCAP  {src->used		{Source capacity}}
	SW      {src->domain.width      {Source block width}}
    }
}

# # ## ### ##### ######## #############
return
