/**************************************************************************/
/*                                                                        */
/*                                 OCaml                                  */
/*                                                                        */
/*                         Fabrice Buoro, Tarides                         */
/*                                                                        */
/*   Copyright 2023 Tarides                                               */
/*                                                                        */
/*   All rights reserved.  This file is distributed under the terms of    */
/*   the GNU Lesser General Public License version 2.1, with the          */
/*   special exception on linking described in the file LICENSE.          */
/*                                                                        */
/**************************************************************************/

#include <assert.h>
#include <stdbool.h>

#define CAML_INTERNALS

#include "caml/mlvalues.h"
#include "caml/globroots.h"
#include "caml/memory.h"


/* runtime/fiber.c */

CAMLprim value caml_alloc_stack(value hval, value hexn, value heff)
{
  assert(false);
  return 0;
}

CAMLprim value caml_continuation_use_noexc (value cont)
{
  assert(false);
  return 0;
}

CAMLprim value caml_continuation_use (value cont)
{
  assert(false);
  return 0;
}

CAMLprim value caml_continuation_use_and_update_handler_noexc(value cont,
    value hval, value hexn, value heff)
{
  assert(false);
  return 0;
}

CAMLprim value caml_drop_continuation (value cont)
{
  assert(false);
  return 0;
}

/* runtime/memory.c */

CAMLprim value caml_atomic_load (value ref)
{
  return Field(ref, 0);
}

CAMLprim value caml_atomic_exchange (value ref, value v)
{
  assert(false);
  return 0;
}

CAMLprim value caml_atomic_cas (value ref, value oldv, value newv)
{
  value* p = Op_val(ref);
  if (*p == oldv) {
    // *p = newv;
    // write_barrier(ref, 0, oldv, newv);
    caml_modify(p, newv);
    return Val_int(1);
  } else {
    return Val_int(0);
  }
  return 0;
}

CAMLprim value caml_atomic_fetch_add (value ref, value incr)
{
  value ret;
  value* p = Op_val(ref);
  CAMLassert(Is_long(*p));
  ret = *p;
  *p = Val_long(Long_val(ret) + Long_val(incr));
  return ret;
}

/* runtime/domain.c */
CAMLprim value caml_domain_spawn(value callback, value mutex)
{
  assert(false);
  return 0;
}

CAMLprim value caml_ml_domain_id(value unit)
{
  assert(false);
  return 0;
}

CAMLprim value caml_ml_domain_unique_token (value unit)
{
  assert(false);
  return 0;
}

CAMLprim value caml_ml_domain_cpu_relax(value t)
{
  assert(false);
  return 0;
}

CAMLprim value caml_domain_dls_set(value t)
{
  caml_modify_generational_global_root(&Caml_state->dls_root, t);
  return Val_unit;
}

CAMLprim value caml_domain_dls_get(value unused)
{
  return Caml_state->dls_root;
}

CAMLprim value caml_ml_domain_set_name(value name)
{
  assert(false);
  return 0;
}

/* runtime/backtrace_nat.c */
CAMLprim value caml_get_continuation_callstack(value cont, value max_frames)
{
  assert(false);
  return 0;
}

/* runtime/intern.c */
CAMLprim value caml_input_value_to_outside_heap(value vchan)
{
  assert(false);
  return 0;
}

/* runtime/obj.c */

CAMLprim value caml_lazy_reset_to_lazy(value v)
{
  assert(false);
  return 0;
}

CAMLprim value caml_lazy_update_to_forward(value v)
{
  // FIXME
  Tag_val (v) = Forward_tag;
  return Val_unit;
}

CAMLprim value caml_lazy_read_result(value v)
{
  assert(false);
  return 0;
}

CAMLprim value caml_lazy_update_to_forcing(value v)
{
  // FIXME
  return Val_int(0);
}

CAMLprim value caml_obj_compare_and_swap (value v, value f, value oldv,
    value newv)
{
  assert(false);
  return 0;
}

CAMLprim value caml_obj_is_shared (value obj)
{
  assert(false);
  return 0;
}

/* runtime/sync.c */

CAMLprim value caml_ml_mutex_new(value unit)
{
  assert(false);
  return 0;
}

CAMLprim value caml_ml_mutex_lock(value wrapper)
{
  assert(false);
  return 0;
}

CAMLprim value caml_ml_mutex_unlock(value wrapper)
{
  assert(false);
  return 0;
}

CAMLprim value caml_ml_mutex_try_lock(value wrapper)
{
  assert(false);
  return 0;
}

CAMLprim value caml_ml_condition_new(value unit)
{
  assert(false);
  return 0;
}

CAMLprim value caml_ml_condition_wait(value wcond, value wmut)
{
  assert(false);
  return 0;
}

CAMLprim value caml_ml_condition_signal(value wrapper)
{
  assert(false);
  return 0;
}

CAMLprim value caml_ml_condition_broadcast(value wrapper)
{
  assert(false);
  return 0;
}

/*  runtime/amd64.S */

void caml_runstack(void)
{
  assert(false);
}

void caml_perform(void)
{
  assert(false);
}

void caml_reperform(void)
{
  assert(false);
}

void caml_resume(void)
{
  assert(false);
}
