import { A } from "@solidjs/router";
import { Button, buttonVariants } from "~/components/ui/button";

export const Main = () => {
    return <div class="bg-slate-700 min-h-screen flex flex-col items-center justify-center text-white">
        <Button onClick={() => console.log("hi")} class="mb-2">
          Start Session
        </Button>
        <A href="/players" class={buttonVariants({variant: "default"})}>
          Edit Players
        </A>
    </div>
}
