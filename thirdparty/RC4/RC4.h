/*
 * An implementation of the ARC4 algorithm
 *
 * Copyright (C) 2001-2003 Christophe Devine
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#ifndef RC4_H
#define RC4_H
/* ************************************************************************** */

/*!
 * \brief rc4_crypt
 * \param key
 * \param key_length
 * \param data
 * \param data_length
 */
void rc4_crypt(const unsigned char *key, const unsigned key_length,
               unsigned char *data, const unsigned data_length);

/* ************************************************************************** */
#endif // RC4_H
