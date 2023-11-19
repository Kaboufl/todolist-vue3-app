/**
 * On définit une interface qui représente notre modèle de données
 * (la structure que nous manipulons pour représenter une entité)
 */
export interface Todo {
  text: string
  done: boolean
  interact?: boolean
  id: number
}
