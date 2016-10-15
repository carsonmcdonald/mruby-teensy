#include "WProgram.h"

#include "mruby.h"
#include "mruby/irep.h"

#include "main_mrb.h"

extern "C" int main(void)
{
  mrb_state *mrb = mrb_open();

  mrb_load_irep(mrb, main_mrb);

  mrb_close(mrb);

  return 0;
}
