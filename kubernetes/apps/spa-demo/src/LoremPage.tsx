import React from "react";

interface Props {
  title: string;
}

const LOREM = `Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed non risus. 
Suspendisse lectus tortor, dignissim sit amet, adipiscing nec, ultricies sed, dolor. 
Cras elementum ultrices diam. Maecenas ligula massa, varius a, semper congue, euismod non, mi. 
Proin porttitor, orci nec nonummy molestie, enim est eleifend mi, non fermentum diam nisl sit amet erat.`;

export default function LoremPage({ title }: Props) {
  return (
    <div>
      <h2>{title}</h2>
      <p>{LOREM}</p>
      <p>{LOREM}</p>
      <p>{LOREM}</p>
    </div>
  );
}
