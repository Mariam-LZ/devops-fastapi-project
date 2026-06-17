import { Flex, Image } from "@chakra-ui/react"
import { Link } from "@tanstack/react-router"

import Logo from "/assets/images/devops-certs-logo.svg"
import UserMenu from "./UserMenu"

function Navbar() {
  return (
    <Flex
      display="flex"
      justify="space-between"
      position="sticky"
      color="white"
      align="center"
      bg="bg.muted"
      w="100%"
      top={0}
      ps={{ base: 14, md: 4 }}
      pe={4}
      py={2}
      m={0}
    >
      <Link to="/">
        <Image
          src={Logo}
          alt="Logo"
          w={{ base: "10rem", md: "12rem" }}
          h="auto"
          p={0}
          m={0}
          display="block"
        />
      </Link>
      <Flex gap={1} alignItems="center" m={0} p={0}>
        <UserMenu />
      </Flex>
    </Flex>
  )
}

export default Navbar
