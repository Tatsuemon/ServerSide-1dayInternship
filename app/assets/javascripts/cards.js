window.onload = () => {
  const cardsList = document.querySelectorAll('.main-card');
  cardsList.forEach((card) => {
    card.addEventListener('click', () => {
      const cardSiblings = getSiblings(card);
      cardSiblings.forEach(sib => {
        sib.classList.toggle('visible');
      });
    });
  });
};

const getSiblings = elem => {
  const siblings = [];
  let sibling = elem.parentNode.firstChild;

  while (sibling) {
    if (sibling.nodeType === 1 && sibling !== elem) {
      siblings.push(sibling);
    };
    sibling = sibling.nextSibling;
  };

  return siblings;
};
