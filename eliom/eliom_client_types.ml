(* Ocsigen
 * http://www.ocsigen.org
 * Module eliom_client_types.ml
 * Copyright (C) 2010 Vincent Balat
 * Laboratoire PPS - CNRS Université Paris Diderot
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, with linking exception;
 * either version 2.1 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 *)

let (>>=) = Lwt.bind

type eliom_data_type =
    ((* The ref tree, to relink the DOM *)
      (XML.ref_tree, (int * XML.ref_tree) list) Ocsigen_lib.leftright *
        (* Table of page data *)
        ((int64 * int) * unit list) *
        (* Tab cookies to set or unset *)
        Ocsigen_cookies.cookieset)

type eliom_appl_answer =
  | EAContent of (eliom_data_type * string)
  | EAExitRedir of string (* Exit the program by doing a redirection -
                             Half XHR redirection. *)

let eliom_appl_answer_content_type = "application/x-eliom"

(* the string is urlencoded because otherwise js does strange things
   with strings ... *)
let encode_eliom_data r =
  Ocsigen_lib.encode ~plus:false (Marshal.to_string r [])



(* Some types are different on client side: *)

type sitedata =
  {site_dir: Ocsigen_lib.url_path;
   site_dir_string: string;
  }


type server_params =
    {
     sp_si: Eliom_common.sess_info;
     sp_sitedata: sitedata (* data for the whole site *);
(*     sp_cookie_info: tables cookie_info; *)
     sp_suffix: Ocsigen_lib.url_path option (* suffix *);
     sp_fullsessname: Eliom_common.fullsessionname option
                                       (* the name of the session
                                          to which belong the service
                                          that answered
                                          (if it is a session service) *)}


type 'a data_key = int64 * int

let to_data_key_ v = v
let of_data_key_ v = v

let string_map f s =
  let r = ref [] in
  for i = String.length s - 1 downto 0 do
    r := f s.[i] :: !r;
  done;
  !r

let string_escape s =
  let l = String.length s in
  let b = Buffer.create (4 * l) in
  let conv = "0123456789abcdef" in
  for i = 0 to l - 1 do
    let c = s.[i] in
    match c with
      '\000' when i = l - 1 || s.[i + 1] < '0' || s.[i + 1] > '9' ->
        Buffer.add_string b "\\0"
    | '\b' ->
        Buffer.add_string b "\\b"
    | '\t' ->
        Buffer.add_string b "\\t"
    | '\n' ->
        Buffer.add_string b "\\n"
    | '\011' ->
        Buffer.add_string b "\\v"
    | '\012' ->
        Buffer.add_string b "\\f"
    | '\r' ->
        Buffer.add_string b "\\r"
    | '\'' ->
        Buffer.add_string b "\\'"
    | '\\' ->
        Buffer.add_string b "\\\\"
    | '\000' .. '\031' | '\127' .. '\255' | '&' | '<' ->
        let c = Char.code c in
        Buffer.add_string b "\\x";
        Buffer.add_char b conv.[c lsr 4];
        Buffer.add_char b conv.[c land 0xf]
    | _ ->
        Buffer.add_char b c
  done;
  Buffer.contents b

let jsmarshal v = string_escape (Marshal.to_string v [])


(* For client side program, we sometimes simulate links and forms
   with client side functions.
   Here are there identifiers: *)
let a_closure_id = 0x0
let a_closure_id_string = Printf.sprintf "0x%02X" a_closure_id

let add_tab_cookies_to_get_form_id = 0x1
let add_tab_cookies_to_get_form_id_string =
  Printf.sprintf "0x%02X" add_tab_cookies_to_get_form_id
let add_tab_cookies_to_post_form_id = 0x2
let add_tab_cookies_to_post_form_id_string =
  Printf.sprintf "0x%02X" add_tab_cookies_to_post_form_id

let add_tab_cookies_to_get_form5_id = 0x3
let add_tab_cookies_to_get_form5_id_string =
  Printf.sprintf "0x%02X" add_tab_cookies_to_get_form5_id
let add_tab_cookies_to_post_form5_id = 0x4
let add_tab_cookies_to_post_form5_id_string =
  Printf.sprintf "0x%02X" add_tab_cookies_to_post_form5_id
