import { A } from "@solidjs/router";
import { buttonVariants } from "~/components/ui/button";

export const Players = () => {
  return (
    <div class="flex flex-col">
      <h1>Players</h1>
      <A href="/players/new" class={`${buttonVariants({ variant: "default" })} mb-2`}>New Player</A>
      <A href="/" class={buttonVariants({ variant: "secondary" })}>Back</A>
    </div>
  );
}
